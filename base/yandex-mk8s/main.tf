locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_file)))
  cluster_sa_roles = toset([
    "k8s.clusters.agent",
    "vpc.publicAdmin",
    "load-balancer.admin",
    "kms.keys.encrypterDecrypter",
  ])
}

data "yandex_vpc_network" "stand" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "stand" {
  name           = "stand"
  description    = "Подсеть машины GitLab и узла кластера"
  zone           = var.zone
  network_id     = data.yandex_vpc_network.stand.id
  v4_cidr_blocks = [var.subnet_cidr]
}

data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2404-lts"
  folder_id = "standard-images"
}

resource "yandex_iam_service_account" "cluster" {
  name        = "stand-mk8s"
  description = "Сервисный аккаунт ресурсов кластера stand-mk8s"
}

resource "yandex_iam_service_account" "node" {
  name        = "stand-mk8s-node"
  description = "Сервисный аккаунт узлов кластера stand-mk8s"
}

resource "yandex_resourcemanager_folder_iam_member" "cluster" {
  for_each = local.cluster_sa_roles

  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "node_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.node.id}"
}

resource "yandex_kms_symmetric_key" "stand" {
  name              = "stand-mk8s"
  description       = "Шифрование секретов кластера stand-mk8s"
  default_algorithm = "AES_256"
}

resource "yandex_vpc_security_group" "internal" {
  name        = "stand-mk8s-internal"
  description = "Служебный трафик мастера и узлов"
  network_id  = data.yandex_vpc_network.stand.id

  ingress {
    description       = "Проверки состояния балансировщика"
    protocol          = "TCP"
    from_port         = 0
    to_port           = 65535
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "Входящий служебный трафик между мастером и узлами"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "ICMP из сетей Yandex Cloud"
    protocol       = "ICMP"
    v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    description       = "Исходящий служебный трафик между мастером и узлами"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }
}

resource "yandex_vpc_security_group" "nodes" {
  name        = "stand-mk8s-nodes"
  description = "Трафик подов, сервисов и исходящий трафик узлов"
  network_id  = data.yandex_vpc_network.stand.id

  ingress {
    description    = "Трафик между подами и сервисами"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [var.cluster_ipv4_range, var.service_ipv4_range]
  }

  egress {
    description    = "Исходящий трафик узлов, включая загрузку образов"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "api" {
  name        = "stand-mk8s-api"
  description = "API Kubernetes и исходящий трафик мастера"
  network_id  = data.yandex_vpc_network.stand.id

  ingress {
    description    = "API Kubernetes, порт 443"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "API Kubernetes, порт 6443"
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Мастер к адресам подов и сервисов"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [var.cluster_ipv4_range, var.service_ipv4_range]
  }

  egress {
    description    = "Синхронизация времени мастера"
    protocol       = "UDP"
    port           = 123
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_kubernetes_cluster" "stand" {
  name        = "stand-mk8s"
  description = "Проверка доставки своего профиля seccomp и AppArmor"
  network_id  = data.yandex_vpc_network.stand.id

  cluster_ipv4_ranges = [var.cluster_ipv4_range]
  service_ipv4_range  = var.service_ipv4_range

  service_account_id      = yandex_iam_service_account.cluster.id
  node_service_account_id = yandex_iam_service_account.node.id

  release_channel = "REGULAR"

  # Туннельный режим не резервирует в облачной сети подсети для подов и сервисов.
  network_implementation {
    cilium {}
  }

  master {
    version   = var.k8s_version
    public_ip = true

    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.stand.id
    }

    security_group_ids = [
      yandex_vpc_security_group.internal.id,
      yandex_vpc_security_group.api.id,
    ]

    maintenance_policy {
      auto_upgrade = false
    }
  }

  kms_provider {
    key_id = yandex_kms_symmetric_key.stand.id
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.cluster,
    yandex_resourcemanager_folder_iam_member.node_puller,
  ]
}

resource "yandex_kubernetes_node_group" "stand" {
  cluster_id  = yandex_kubernetes_cluster.stand.id
  name        = "stand-mk8s"
  description = "Единственный узел проверки доставки профиля"
  version     = var.k8s_version

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = var.node_cores
      memory        = var.node_memory
      core_fraction = 100
    }

    boot_disk {
      type = "network-ssd"
      size = var.node_disk_gb
    }

    # С Kubernetes 1.24 Docker не поддерживается. Без блока API всё равно ставит containerd.
    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.stand.id]
      security_group_ids = [
        yandex_vpc_security_group.internal.id,
        yandex_vpc_security_group.nodes.id,
      ]
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  # В зоне нет свободной квоты на вторую машину и второй диск.
  # Узел заменяется на месте: новый экземпляр рядом не создаётся.
  deploy_policy {
    max_expansion   = 0
    max_unavailable = 1
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair  = true
  }
}

resource "yandex_vpc_security_group" "gitlab" {
  name        = "stand-gitlab"
  description = "SSH администратора, HTTP, HTTPS, SSH GitLab и API k3s"
  network_id  = data.yandex_vpc_network.stand.id

  ingress {
    description    = "SSH администратора"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTP GitLab"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS GitLab"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "SSH GitLab для clone и push"
    protocol       = "TCP"
    port           = 2222
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "API k3s"
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Исходящий трафик для загрузки образа"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

data "yandex_vpc_address" "gitlab" {
  name = var.gitlab_address_name
}

resource "yandex_compute_disk" "gitlab" {
  name     = "stand-gitlab"
  type     = "network-ssd"
  zone     = var.zone
  size     = var.gitlab_disk_gb
  image_id = data.yandex_compute_image.ubuntu.id

  # Образ задаёт содержимое только при создании. Увеличение size меняет тот же диск.
  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "yandex_compute_instance" "gitlab" {
  name        = "stand-gitlab"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 8
    core_fraction = 100
  }

  boot_disk {
    disk_id = yandex_compute_disk.gitlab.id
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.stand.id
    nat            = true
    nat_ip_address = data.yandex_vpc_address.gitlab.external_ipv4_address[0].address
    security_group_ids = [
      yandex_vpc_security_group.gitlab.id,
    ]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_public_key}"
    user-data = templatefile("${path.module}/cloud-init/gitlab.yaml.tftpl", {
      gitlab_image               = var.gitlab_image
      gitlab_letsencrypt_enabled = var.gitlab_letsencrypt_enabled
      gitlab_domain              = var.gitlab_domain
      gitlab_public_ip           = data.yandex_vpc_address.gitlab.external_ipv4_address[0].address
      gitlab_acme_email          = var.gitlab_acme_email
      k3s_version                = var.k3s_version
      k3s_tls_san                = data.yandex_vpc_address.gitlab.external_ipv4_address[0].address
    })
  }

  # cloud-init читает user-data один раз. Повторная запись метаданных скрипт не запускает.
  lifecycle {
    ignore_changes = [metadata]
  }

  allow_stopping_for_update = true
}

resource "terraform_data" "kubeconfig" {
  triggers_replace = [
    yandex_compute_instance.gitlab.id,
    yandex_kubernetes_cluster.stand.id,
    data.yandex_vpc_address.gitlab.external_ipv4_address[0].address,
  ]

  provisioner "local-exec" {
    command = "bash \"${path.module}/kubeconfig.sh\""
    environment = {
      KUBECONFIG_DIR = "${path.module}/kubeconfig"
      K3S_HOST       = data.yandex_vpc_address.gitlab.external_ipv4_address[0].address
      K3S_SSH_KEY    = trimsuffix(pathexpand(var.ssh_public_key_file), ".pub")
      CLUSTER_ID     = yandex_kubernetes_cluster.stand.id
      CLOUD_ID       = var.cloud_id
      FOLDER_ID      = var.folder_id
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f \"${path.module}/kubeconfig/k3s.kubeconfig\" \"${path.module}/kubeconfig/mk8s.kubeconfig\""
  }
}
