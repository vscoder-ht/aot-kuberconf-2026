Команды кейса версии GitLab Runner. Манифест не применяем. Values на стенд не ставим: [values-native.yaml](values-native.yaml) — нативные секции, [values-patch.yaml](values-patch.yaml) — патч и аннотация. Поды заданий появляются после ручного запуска заданий в GitLab. Пока заданий нет, в списке только поды самих Runner.

В каждом Helm-релизе шаги идут в одном порядке: values, имя пода задания, затем проверка, доехали ли значения до контейнера `build`. Из values `yq` убирает `runnerToken`. Смотрим строку `runners.config`. Имя пода из колонки POD подставляем вместо `POD`. Проверка оставляет пути манифеста: аннотацию в `metadata.annotations` и `securityContext` у контейнера `build`. Полный объект пода не выводим.

## 1. Helm-релиз `v_18_10_native`

### Values

Прочитать values, с которыми Helm применил Helm-релиз `mk8s-v-18-10-native`. Исходные значения: [values-native.yaml](values-native.yaml).
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
helm -n gitlab-runner get values mk8s-v-18-10-native -o yaml | yq 'del(.runnerToken)'
```

### Имя пода задания

Прочитать имя пода задания `v_18_10_native`. У подов самого Runner в колонке JOB будет `<none>`.
```bash
kubectl -n gitlab-runner get pods -o 'custom-columns=POD:.metadata.name,JOB:.spec.containers[?(@.name=="build")].env[?(@.name=="CI_JOB_NAME")].value'
```

### Доехали ли значения

Прочитать аннотацию AppArmor и `securityContext` контейнера `build` у пода задания `v_18_10_native`.
```bash
kubectl -n gitlab-runner get pod POD -o yaml | yq '
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


## 2. Helm-релиз `v_18_10_patch`

### Values

Прочитать values, с которыми Helm применил Helm-релиз `mk8s-v-18-10-patch`. Исходные значения: [values-patch.yaml](values-patch.yaml).
```bash
helm -n gitlab-runner get values mk8s-v-18-10-patch -o yaml | yq 'del(.runnerToken)'
```

### Имя пода задания

Прочитать имя пода задания `v_18_10_patch`. У подов самого Runner в колонке JOB будет `<none>`.
```bash
kubectl -n gitlab-runner get pods -o 'custom-columns=POD:.metadata.name,JOB:.spec.containers[?(@.name=="build")].env[?(@.name=="CI_JOB_NAME")].value'
```

### Доехали ли значения

Прочитать аннотацию AppArmor и `securityContext` контейнера `build` у пода задания `v_18_10_patch`.
```bash
kubectl -n gitlab-runner get pod POD -o yaml | yq '
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


## 3. Helm-релиз `v_19_5_native`

### Values

Прочитать values, с которыми Helm применил Helm-релиз `mk8s-v-19-5-native`. Исходные значения: [values-native.yaml](values-native.yaml).
```bash
helm -n gitlab-runner get values mk8s-v-19-5-native -o yaml | yq 'del(.runnerToken)'
```

### Имя пода задания

Прочитать имя пода задания `v_19_5_native`. У подов самого Runner в колонке JOB будет `<none>`.
```bash
kubectl -n gitlab-runner get pods -o 'custom-columns=POD:.metadata.name,JOB:.spec.containers[?(@.name=="build")].env[?(@.name=="CI_JOB_NAME")].value'
```

### Доехали ли значения

Прочитать аннотацию AppArmor и `securityContext` контейнера `build` у пода задания `v_19_5_native`.
```bash
kubectl -n gitlab-runner get pod POD -o yaml | yq '
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


