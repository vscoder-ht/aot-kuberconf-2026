data "external" "gitlab_token" {
  count = var.gitlab_external_enabled ? 0 : 1

  program = ["bash", "${path.module}/gitlab-token.sh"]

  query = {
    host        = var.gitlab_public_ip
    username    = var.gitlab_username
    create_user = var.gitlab_user_create_enabled ? "true" : "false"
  }
}

locals {
  gitlab_token = concat(
    data.external.gitlab_token[*].result.token,
    [var.gitlab_token],
  )[0]

  gitlab_url           = trimsuffix(var.gitlab_base_url, "/api/v4")
  k3s_enabled          = var.k3s_kubeconfig_path != ""
  mk8s_enabled         = var.mk8s_kubeconfig_path != ""
  enabled_clusters     = toset(compact([local.k3s_enabled ? "k3s" : "", local.mk8s_enabled ? "mk8s" : ""]))
  kubeconfig_fallback  = local.k3s_enabled ? var.k3s_kubeconfig_path : var.mk8s_kubeconfig_path
  helm_k3s_kubeconfig  = local.k3s_enabled ? var.k3s_kubeconfig_path : local.kubeconfig_fallback
  helm_mk8s_kubeconfig = local.mk8s_enabled ? var.mk8s_kubeconfig_path : local.kubeconfig_fallback
}

resource "gitlab_group" "stand" {
  name             = var.gitlab_group_path
  path             = var.gitlab_group_path
  visibility_level = "private"
}

resource "gitlab_project" "stand" {
  for_each = local.enabled_clusters

  name             = "stand-${each.key}"
  path             = "stand-${each.key}"
  namespace_id     = gitlab_group.stand.id
  visibility_level = "private"
}

resource "gitlab_branch_protection" "main" {
  for_each = local.enabled_clusters

  project            = gitlab_project.stand[each.key].id
  branch             = "main"
  push_access_level  = "admin"
  merge_access_level = "admin"
}

