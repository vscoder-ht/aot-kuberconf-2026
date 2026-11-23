resource "gitlab_user_runner" "k3s_v_18_10_native" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 18.10. Тип конфигурации native. Кластер k3s."
  tag_list    = ["k3s_v_18_10_native"]
  untagged    = false
}

resource "helm_release" "k3s_v_18_10_native" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-18-10-native"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.87.1"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_18_10_native.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_18_10_native[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_18_10_native" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 18.10. Тип конфигурации native. Кластер mk8s."
  tag_list    = ["mk8s_v_18_10_native"]
  untagged    = false
}

resource "helm_release" "mk8s_v_18_10_native" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-18-10-native"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.87.1"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_18_10_native.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_18_10_native[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_18_10_patch" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 18.10. Тип конфигурации patch. Кластер k3s."
  tag_list    = ["k3s_v_18_10_patch"]
  untagged    = false
}

resource "helm_release" "k3s_v_18_10_patch" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-18-10-patch"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.87.1"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_18_10_patch.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_18_10_patch[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_18_10_patch" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 18.10. Тип конфигурации patch. Кластер mk8s."
  tag_list    = ["mk8s_v_18_10_patch"]
  untagged    = false
}

resource "helm_release" "mk8s_v_18_10_patch" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-18-10-patch"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.87.1"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_18_10_patch.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_18_10_patch[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_19_3_native" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 19.5. Тип конфигурации native. Кластер k3s."
  tag_list    = ["k3s_v_19_5_native"]
  untagged    = false
}

resource "helm_release" "k3s_v_19_3_native" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-19-5-native"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_native.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_19_3_native[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_19_3_native" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 19.5. Тип конфигурации native. Кластер mk8s."
  tag_list    = ["mk8s_v_19_5_native"]
  untagged    = false
}

resource "helm_release" "mk8s_v_19_3_native" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-19-5-native"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_native.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_19_3_native[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_19_3_patch" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 19.5. Тип конфигурации patch. Кластер k3s."
  tag_list    = ["k3s_v_19_5_patch"]
  untagged    = false
}

resource "helm_release" "k3s_v_19_3_patch" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-19-3-patch"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_patch.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_19_3_patch[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_19_3_patch" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 19.5. Тип конфигурации patch. Кластер mk8s."
  tag_list    = ["mk8s_v_19_5_patch"]
  untagged    = false
}

resource "helm_release" "mk8s_v_19_3_patch" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-19-3-patch"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_patch.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_19_3_patch[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_19_3_unconfined" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 19.5. Тип конфигурации native. Профиль seccomp Unconfined. Кластер k3s."
  tag_list    = ["k3s_v_19_5_unconfined"]
  untagged    = false
}

resource "helm_release" "k3s_v_19_3_unconfined" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-19-3-unconfined"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_unconfined.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_19_3_unconfined[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_19_3_unconfined" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 19.5. Тип конфигурации native. Профиль seccomp Unconfined. Кластер mk8s."
  tag_list    = ["mk8s_v_19_5_unconfined"]
  untagged    = false
}

resource "helm_release" "mk8s_v_19_3_unconfined" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-19-3-unconfined"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_unconfined.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_19_3_unconfined[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_19_3_runtime_default" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 19.5. Тип конфигурации native. Профиль seccomp RuntimeDefault. Кластер k3s."
  tag_list    = ["k3s_v_19_5_runtime_default"]
  untagged    = false
}

resource "helm_release" "k3s_v_19_3_runtime_default" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-19-3-runtime-default"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_runtime_default.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_19_3_runtime_default[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_19_3_runtime_default" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 19.5. Тип конфигурации native. Профиль seccomp RuntimeDefault. Кластер mk8s."
  tag_list    = ["mk8s_v_19_5_runtime_default"]
  untagged    = false
}

resource "helm_release" "mk8s_v_19_3_runtime_default" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-19-3-runtime-default"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_runtime_default.yaml", {
      gitlab_url = local.gitlab_url
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_19_3_runtime_default[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_19_3_buildkit_rootless" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 19.5. BuildKit rootless. Кластер k3s."
  tag_list    = ["k3s_v_19_5_buildkit_rootless"]
  untagged    = false
}

resource "helm_release" "k3s_v_19_3_buildkit_rootless" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-19-3-buildkit-rootless"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_buildkit_rootless.yaml", {
      gitlab_url                 = local.gitlab_url
      seccomp_type               = "Unconfined"
      seccomp_localhost_profile  = ""
      apparmor_type              = "Unconfined"
      apparmor_localhost_profile = ""
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_19_3_buildkit_rootless[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_19_3_buildkit_rootless" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 19.5. BuildKit rootless. Кластер mk8s."
  tag_list    = ["mk8s_v_19_5_buildkit_rootless"]
  untagged    = false
}

resource "helm_release" "mk8s_v_19_3_buildkit_rootless" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-19-3-buildkit-rootless"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_buildkit_rootless.yaml", {
      gitlab_url                 = local.gitlab_url
      seccomp_type               = "Localhost"
      seccomp_localhost_profile  = "stand-buildkit.json"
      apparmor_type              = "Localhost"
      apparmor_localhost_profile = "stand-buildkit"
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_19_3_buildkit_rootless[0].token
    }
  ]
}

resource "gitlab_user_runner" "k3s_v_19_3_buildkit_privileged" {
  count = local.k3s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["k3s"].id
  description = "Версия 19.5. BuildKit privileged. Кластер k3s."
  tag_list    = ["k3s_v_19_5_buildkit_privileged"]
  untagged    = false
}

resource "helm_release" "k3s_v_19_3_buildkit_privileged" {
  count    = local.k3s_enabled ? 1 : 0
  provider = helm.k3s

  name             = "k3s-v-19-3-buildkit-privileged"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_buildkit_privileged.yaml", {
      gitlab_url                 = local.gitlab_url
      seccomp_type               = "Unconfined"
      seccomp_localhost_profile  = ""
      apparmor_type              = "Unconfined"
      apparmor_localhost_profile = ""
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.k3s_v_19_3_buildkit_privileged[0].token
    }
  ]
}

resource "gitlab_user_runner" "mk8s_v_19_3_buildkit_privileged" {
  count = local.mk8s_enabled ? 1 : 0

  runner_type = "project_type"
  project_id  = gitlab_project.stand["mk8s"].id
  description = "Версия 19.5. BuildKit privileged. Кластер mk8s."
  tag_list    = ["mk8s_v_19_5_buildkit_privileged"]
  untagged    = false
}

resource "helm_release" "mk8s_v_19_3_buildkit_privileged" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "mk8s-v-19-3-buildkit-privileged"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  version          = "0.94.3"
  namespace        = "gitlab-runner"
  create_namespace = true

  values = [
    templatefile("${path.module}/templates/v_19_3_buildkit_privileged.yaml", {
      gitlab_url                 = local.gitlab_url
      seccomp_type               = "Localhost"
      seccomp_localhost_profile  = "stand-buildkit.json"
      apparmor_type              = "Localhost"
      apparmor_localhost_profile = "stand-buildkit"
    })
  ]

  set_sensitive = [
    {
      name  = "runnerToken"
      value = gitlab_user_runner.mk8s_v_19_3_buildkit_privileged[0].token
    }
  ]
}

resource "helm_release" "mk8s_stand_buildkit_profiles" {
  count    = local.mk8s_enabled ? 1 : 0
  provider = helm.mk8s

  name             = "stand-buildkit-profiles"
  chart            = "${path.module}/profiles"
  namespace        = "gitlab-runner"
  create_namespace = true

  depends_on = [helm_release.mk8s_v_18_10_native]
}
