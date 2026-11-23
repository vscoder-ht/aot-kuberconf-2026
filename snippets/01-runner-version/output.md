Записанный вывод кейса версии GitLab Runner. Показывать, если стенд не отвечает.

Прогон 21 ноября 2026, контекст `yc-stand-mk8s`, Kubernetes `v1.35.1`, пространство имён `gitlab-runner`.
Три пода заданий в `Running`. Команды и порядок совпадают со [snippet.md](snippet.md). Из values удалена строка `runnerToken`. Полный объект пода не записывался.

## 1. Helm-релиз `v_18_10_native`

### Values

```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
helm -n gitlab-runner get values mk8s-v-18-10-native -o yaml | yq 'del(.runnerToken)'
```

```yaml
gitlabUrl: https://gitlab.example.com
image:
  tag: alpine-v18.10.1
rbac:
  create: true
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine:3.20"
        [runners.kubernetes.build_container_security_context.seccomp_profile]
          type = "RuntimeDefault"
        [runners.kubernetes.build_container_security_context.app_armor_profile]
          type = "RuntimeDefault"
  executor: kubernetes
```

### Имя пода задания

```bash
kubectl -n gitlab-runner get pods -o 'custom-columns=POD:.metadata.name,JOB:.spec.containers[?(@.name=="build")].env[?(@.name=="CI_JOB_NAME")].value'
```

```text
POD                                                              JOB
mk8s-v-18-10-native-gitlab-runner-d969c77bd-qwfk4                <none>
mk8s-v-18-10-patch-gitlab-runner-cfb49d98c-q7kxd                 <none>
mk8s-v-19-3-buildkit-privileged-gitlab-runner-678686dcb9-v55nc   <none>
mk8s-v-19-3-buildkit-rootless-gitlab-runner-98c56857d-hnxkr      <none>
mk8s-v-19-3-patch-gitlab-runner-7969dd976b-fzwq6                 <none>
mk8s-v-19-3-runtime-default-gitlab-runner-587b58557f-xsghw       <none>
mk8s-v-19-3-unconfined-gitlab-runner-84c574dd89-f6llr            <none>
mk8s-v-19-5-native-gitlab-runner-994f88789-58wz7                 <none>
runner-6jcw-ecnz-project-1-concurrent-0-prj786iv                 v_18_10_native
runner-ftjw52v65-project-1-concurrent-0-gdql7tfe                 v_18_10_patch
runner-jjb7vkfzx-project-1-concurrent-0-bh2her8f                 v_19_5_native
```

Под задания `v_18_10_native`: `runner-6jcw-ecnz-project-1-concurrent-0-prj786iv`.

### Доехали ли значения

```bash
kubectl -n gitlab-runner get pod runner-6jcw-ecnz-project-1-concurrent-0-prj786iv -o yaml | yq '
{
  "metadata": {
    "annotations": (.metadata.annotations | pick(["container.apparmor.security.beta.kubernetes.io/build"]))
  },
  "spec": {
    "containers": [
      .spec.containers[] | select(.name == "build") | pick(["name", "securityContext"])
    ]
  }
}'
```

```yaml
metadata:
  annotations: {}
spec:
  containers:
    - name: build
      securityContext:
        capabilities:
          drop:
            - NET_RAW
```


## 2. Helm-релиз `v_18_10_patch`

### Values

```bash
helm -n gitlab-runner get values mk8s-v-18-10-patch -o yaml | yq 'del(.runnerToken)'
```

```yaml
gitlabUrl: https://gitlab.example.com
image:
  tag: alpine-v18.10.1
rbac:
  create: true
runners:
  config: |
    [[runners]]
      [runners.feature_flags]
        FF_USE_ADVANCED_POD_SPEC_CONFIGURATION = true
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine:3.20"
        [runners.kubernetes.pod_annotations]
          "container.apparmor.security.beta.kubernetes.io/build" = "runtime/default"
        [[runners.kubernetes.pod_spec]]
          name = "build seccomp RuntimeDefault"
          patch_type = "strategic"
          patch = '''
            containers:
            - name: build
              securityContext:
                seccompProfile:
                  type: RuntimeDefault
          '''
  executor: kubernetes
```

### Имя пода задания

```bash
kubectl -n gitlab-runner get pods -o 'custom-columns=POD:.metadata.name,JOB:.spec.containers[?(@.name=="build")].env[?(@.name=="CI_JOB_NAME")].value'
```

```text
POD                                                              JOB
mk8s-v-18-10-native-gitlab-runner-d969c77bd-qwfk4                <none>
mk8s-v-18-10-patch-gitlab-runner-cfb49d98c-q7kxd                 <none>
mk8s-v-19-3-buildkit-privileged-gitlab-runner-678686dcb9-v55nc   <none>
mk8s-v-19-3-buildkit-rootless-gitlab-runner-98c56857d-hnxkr      <none>
mk8s-v-19-3-patch-gitlab-runner-7969dd976b-fzwq6                 <none>
mk8s-v-19-3-runtime-default-gitlab-runner-587b58557f-xsghw       <none>
mk8s-v-19-3-unconfined-gitlab-runner-84c574dd89-f6llr            <none>
mk8s-v-19-5-native-gitlab-runner-994f88789-58wz7                 <none>
runner-6jcw-ecnz-project-1-concurrent-0-prj786iv                 v_18_10_native
runner-ftjw52v65-project-1-concurrent-0-gdql7tfe                 v_18_10_patch
runner-jjb7vkfzx-project-1-concurrent-0-bh2her8f                 v_19_5_native
```

Под задания `v_18_10_patch`: `runner-ftjw52v65-project-1-concurrent-0-gdql7tfe`.

### Доехали ли значения

```bash
kubectl -n gitlab-runner get pod runner-ftjw52v65-project-1-concurrent-0-gdql7tfe -o yaml | yq '
{
  "metadata": {
    "annotations": (.metadata.annotations | pick(["container.apparmor.security.beta.kubernetes.io/build"]))
  },
  "spec": {
    "containers": [
      .spec.containers[] | select(.name == "build") | pick(["name", "securityContext"])
    ]
  }
}'
```

```yaml
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io/build: runtime/default
spec:
  containers:
    - name: build
      securityContext:
        appArmorProfile:
          type: RuntimeDefault
        capabilities:
          drop:
            - NET_RAW
        seccompProfile:
          type: RuntimeDefault
```


## 3. Helm-релиз `v_19_5_native`

### Values

```bash
helm -n gitlab-runner get values mk8s-v-19-5-native -o yaml | yq 'del(.runnerToken)'
```

```yaml
gitlabUrl: https://gitlab.example.com
image:
  tag: alpine-v19.5.3
rbac:
  create: true
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine:3.20"
        [runners.kubernetes.build_container_security_context.seccomp_profile]
          type = "RuntimeDefault"
        [runners.kubernetes.build_container_security_context.app_armor_profile]
          type = "RuntimeDefault"
  executor: kubernetes
```

### Имя пода задания

```bash
kubectl -n gitlab-runner get pods -o 'custom-columns=POD:.metadata.name,JOB:.spec.containers[?(@.name=="build")].env[?(@.name=="CI_JOB_NAME")].value'
```

```text
POD                                                              JOB
mk8s-v-18-10-native-gitlab-runner-d969c77bd-qwfk4                <none>
mk8s-v-18-10-patch-gitlab-runner-cfb49d98c-q7kxd                 <none>
mk8s-v-19-3-buildkit-privileged-gitlab-runner-678686dcb9-v55nc   <none>
mk8s-v-19-3-buildkit-rootless-gitlab-runner-98c56857d-hnxkr      <none>
mk8s-v-19-3-patch-gitlab-runner-7969dd976b-fzwq6                 <none>
mk8s-v-19-3-runtime-default-gitlab-runner-587b58557f-xsghw       <none>
mk8s-v-19-3-unconfined-gitlab-runner-84c574dd89-f6llr            <none>
mk8s-v-19-5-native-gitlab-runner-994f88789-58wz7                 <none>
runner-6jcw-ecnz-project-1-concurrent-0-prj786iv                 v_18_10_native
runner-ftjw52v65-project-1-concurrent-0-gdql7tfe                 v_18_10_patch
runner-jjb7vkfzx-project-1-concurrent-0-bh2her8f                 v_19_5_native
```

Под задания `v_19_5_native`: `runner-jjb7vkfzx-project-1-concurrent-0-bh2her8f`.

### Доехали ли значения

```bash
kubectl -n gitlab-runner get pod runner-jjb7vkfzx-project-1-concurrent-0-bh2her8f -o yaml | yq '
{
  "metadata": {
    "annotations": (.metadata.annotations | pick(["container.apparmor.security.beta.kubernetes.io/build"]))
  },
  "spec": {
    "containers": [
      .spec.containers[] | select(.name == "build") | pick(["name", "securityContext"])
    ]
  }
}'
```

```yaml
metadata:
  annotations: {}
spec:
  containers:
    - name: build
      securityContext:
        appArmorProfile:
          type: RuntimeDefault
        capabilities:
          drop:
            - NET_RAW
        seccompProfile:
          type: RuntimeDefault
```
