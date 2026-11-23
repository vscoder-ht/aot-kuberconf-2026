terraform {
  required_version = ">= 1.9"

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 19.5"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
}

provider "gitlab" {
  token    = local.gitlab_token
  base_url = var.gitlab_base_url
}

provider "helm" {
  alias = "k3s"
  kubernetes = {
    config_path = local.helm_k3s_kubeconfig
  }
}

provider "helm" {
  alias = "mk8s"
  kubernetes = {
    config_path = local.helm_mk8s_kubeconfig
  }
}
