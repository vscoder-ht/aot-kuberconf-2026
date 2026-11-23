variable "gitlab_public_ip" {
  description = "Публичный адрес машины GitLab. Выход gitlab_public_ip каталога base/yandex-mk8s. Нужен при выключенном gitlab_external_enabled. В репозиторий не записывается."
  type        = string
  default     = ""
}

variable "k3s_public_ip" {
  description = "Публичный адрес API k3s. Совпадает с адресом машины GitLab. Каталог значение не читает. В репозиторий не записывается."
  type        = string
  default     = ""
}

variable "gitlab_username" {
  description = "Пользователь GitLab, которому выпускается токен."
  type        = string
  default     = "terraform"

  validation {
    condition     = length(var.gitlab_username) > 0 && length(regexall("\"", var.gitlab_username)) == 0
    error_message = "Имя пользователя GitLab задаётся без кавычек и не может быть пустым."
  }
}

variable "gitlab_user_create_enabled" {
  description = "Создавать пользователя gitlab_username, если его ещё нет. Выключенный флаг требует, чтобы пользователь уже существовал. При включённом gitlab_external_enabled не используется."
  type        = bool
  default     = true
}

variable "gitlab_external_enabled" {
  description = "Подключать уже существующий GitLab. Токен берётся из gitlab_token, пользователь на машине не создаётся."
  type        = bool
  default     = false

  validation {
    condition     = var.gitlab_external_enabled || length(var.gitlab_public_ip) > 0
    error_message = "При выключенном gitlab_external_enabled запишите TF_VAR_gitlab_public_ip."
  }

  validation {
    condition     = !var.gitlab_external_enabled || length(var.gitlab_token) > 0
    error_message = "При включённом gitlab_external_enabled запишите TF_VAR_gitlab_token."
  }
}

variable "gitlab_token" {
  description = "Токен доступа уже существующего GitLab с областью api. Нужен при включённом gitlab_external_enabled. В репозиторий не записывается."
  type        = string
  default     = ""
  sensitive   = true
}

variable "gitlab_group_path" {
  description = "Путь группы GitLab, в которой создаются проекты. Пользователь gitlab_username остаётся владельцем токена, не пространством проектов."
  type        = string
  default     = "stand"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.gitlab_group_path))
    error_message = "Путь группы — строчные буквы, цифры и дефис."
  }
}

variable "gitlab_base_url" {
  description = "Базовый URL API GitLab, с суффиксом /api/v4. В репозиторий не записывается."
  type        = string
}

variable "k3s_kubeconfig_path" {
  description = "Путь к kubeconfig k3s. Пустая строка не создаёт проект stand/stand-k3s и его Helm-релизы. В репозиторий не входит."
  type        = string
  default     = ""
}

variable "mk8s_kubeconfig_path" {
  description = "Путь к kubeconfig управляемого кластера. Пустая строка не создаёт проект stand/stand-mk8s и его Helm-релизы. В репозиторий не входит."
  type        = string
  default     = ""

  validation {
    condition     = var.k3s_kubeconfig_path != "" || var.mk8s_kubeconfig_path != ""
    error_message = "Заполните TF_VAR_k3s_kubeconfig_path или TF_VAR_mk8s_kubeconfig_path."
  }
}
