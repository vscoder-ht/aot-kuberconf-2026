variable "cloud_id" {
  description = "Идентификатор облака. Задаётся в .tfenv."
  type        = string

  validation {
    condition     = length(trimspace(var.cloud_id)) > 0
    error_message = "Задайте cloud_id."
  }
}

variable "folder_id" {
  description = "Идентификатор каталога. Задаётся в .tfenv."
  type        = string

  validation {
    condition     = length(trimspace(var.folder_id)) > 0
    error_message = "Задайте folder_id."
  }
}

variable "network_name" {
  description = "Имя уже существующей сети VPC. Каталог создаёт в ней подсеть stand и новую сеть не создаёт. По умолчанию default. Задаётся в .tfenv."
  type        = string
  default     = "default"

  validation {
    condition     = length(trimspace(var.network_name)) > 0
    error_message = "Задайте network_name."
  }
}

variable "zone" {
  description = "Зона машины GitLab, мастера, узла и подсети. Задаётся в .tfenv."
  type        = string

  validation {
    condition     = length(trimspace(var.zone)) > 0
    error_message = "Задайте zone."
  }
}

variable "subnet_cidr" {
  description = "CIDR подсети stand в сети network_name. Не должен пересекаться с CIDR подов и сервисов."
  type        = string
  default     = "10.128.0.0/24"
}

variable "ssh_public_key_file" {
  description = "Открытый ключ администратора машины GitLab. Закрытый ключ Terraform не создаёт."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "gitlab_image" {
  description = "Образ GitLab CE."
  type        = string
  default     = "gitlab/gitlab-ce:19.5.8-ce.0"
}

variable "k3s_version" {
  description = "Версия k3s, которую запускает установщик на машине GitLab. Не новее проверенной стабильной линии на момент сборки кода."
  type        = string
  default     = "v1.34.12+k3s1"
}

variable "gitlab_disk_gb" {
  description = "Диск машины GitLab, ГБ. На стенде 30. Нижняя граница документации стеснённой установки — 20."
  type        = number
  default     = 30
}

variable "gitlab_letsencrypt_enabled" {
  description = "Включает HTTPS и встроенный Let's Encrypt GitLab. Порты 80, 443 и 2222 открыты снаружи в любом режиме."
  type        = bool
  default     = true
}

variable "gitlab_domain" {
  description = "Имя GitLab для external_url. Обязательно при gitlab_letsencrypt_enabled. В репозиторий не записывается."
  type        = string
  default     = ""

  validation {
    condition     = !var.gitlab_letsencrypt_enabled || length(trimspace(var.gitlab_domain)) > 0
    error_message = "При gitlab_letsencrypt_enabled задайте gitlab_domain."
  }
}

variable "gitlab_acme_email" {
  description = "Почта для уведомлений Let's Encrypt. Обязательна при gitlab_letsencrypt_enabled. В репозиторий не записывается."
  type        = string
  default     = ""

  validation {
    condition     = !var.gitlab_letsencrypt_enabled || length(trimspace(var.gitlab_acme_email)) > 0
    error_message = "При gitlab_letsencrypt_enabled задайте gitlab_acme_email."
  }
}

variable "gitlab_address_name" {
  description = "Имя зарезервированного публичного адреса GitLab. Адрес создаёт yc, Terraform его только читает. В репозиторий не записывается."
  type        = string
  default     = ""

  validation {
    condition     = length(trimspace(var.gitlab_address_name)) > 0
    error_message = "Задайте gitlab_address_name."
  }
}

variable "k8s_version" {
  description = "Минорная версия Kubernetes мастера и группы узлов. Канал REGULAR позволяет выключить автообновление."
  type        = string
  default     = "1.35"
}

variable "node_cores" {
  description = "Число vCPU единственного узла."
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "Память единственного узла, ГБ."
  type        = number
  default     = 4
}

variable "node_disk_gb" {
  description = "Загрузочный диск узла. Нижняя граница группы узлов Managed Kubernetes — 64 ГБ."
  type        = number
  default     = 64
}

variable "cluster_ipv4_range" {
  description = "CIDR адресов подов. Не должен пересекаться с подсетью stand."
  type        = string
  default     = "10.96.0.0/16"
}

variable "service_ipv4_range" {
  description = "CIDR адресов сервисов. Не должен пересекаться с подсетью и с CIDR подов."
  type        = string
  default     = "10.112.0.0/16"
}
