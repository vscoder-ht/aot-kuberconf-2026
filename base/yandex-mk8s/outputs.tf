output "gitlab_public_ip" {
  description = "Публичный адрес машины GitLab для входа администратора."
  value       = data.yandex_vpc_address.gitlab.external_ipv4_address[0].address
}

output "gitlab_ssh" {
  description = "Команда входа администратора на машину GitLab по SSH, порт 22."
  value       = "ssh ubuntu@${data.yandex_vpc_address.gitlab.external_ipv4_address[0].address}"
}

output "gitlab_url" {
  description = "Адрес веб-интерфейса GitLab снаружи. При включённом Let's Encrypt это https и имя из gitlab_domain, иначе http и публичный адрес машины."
  value = (
    var.gitlab_letsencrypt_enabled
    ? "https://${var.gitlab_domain}"
    : "http://${data.yandex_vpc_address.gitlab.external_ipv4_address[0].address}"
  )
}

output "k3s_public_ip" {
  description = "Публичный адрес API k3s. Совпадает с адресом машины GitLab."
  value       = data.yandex_vpc_address.gitlab.external_ipv4_address[0].address
}

output "gitlab_private_ip" {
  description = "Адрес интерфейса GitLab в подсети машины."
  value       = yandex_compute_instance.gitlab.network_interface[0].ip_address
}

output "cluster_id" {
  description = "Идентификатор кластера."
  value       = yandex_kubernetes_cluster.stand.id
}

output "k3s_kubeconfig_path" {
  description = "Файл kubeconfig k3s. Пишет apply, в репозиторий не входит."
  value       = abspath("${path.module}/kubeconfig/k3s.kubeconfig")
  depends_on  = [terraform_data.kubeconfig]
}

output "mk8s_kubeconfig_path" {
  description = "Файл kubeconfig управляемого кластера. Пишет apply, в репозиторий не входит."
  value       = abspath("${path.module}/kubeconfig/mk8s.kubeconfig")
  depends_on  = [terraform_data.kubeconfig]
}

output "master_endpoint" {
  description = "Внешний адрес API Kubernetes."
  value       = yandex_kubernetes_cluster.stand.master[0].external_v4_endpoint
}
