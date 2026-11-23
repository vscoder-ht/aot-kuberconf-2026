# Доехала ли настройка до контейнера build

Смысл настройки один: seccomp и AppArmor профили заданы явно но разными способами. Смотрим контейнер `build` трёх подов задания. Доходит настройка или нет — решает версия Runner.

## Схема

GitLab стоит отдельно. Три Runner работают в Kubernetes, в пространстве имён `gitlab-runner`, на узле кластера.

```text
 GitLab CE 19.5.8                         Kubernetes
 отдельная машина                         пространство имён gitlab-runner
 ┌────────────────────┐                   ┌──────────────────────────────────┐
 │                    │     задание       │  узел                            │
 │  координатор       │ ────────────────► │                                  │
 │                    │                   │  Runner 18.10.1    native        │
 │                    │                   │  Runner 18.10.1    patch         │
 │                    │                   │  Runner 19.5.3     native        │
 └────────────────────┘                   └──────────────────────────────────┘
```

| Runner | Версия | Как заданы seccomp и AppArmor |
| --- | --- | --- |
| `v_18_10_native` | 18.10.1 | нативные секции |
| `v_18_10_patch` | 18.10.1 | патч `pod_spec` и аннотация пода |
| `v_19_5_native` | 19.5.3 | те же нативные секции |

Задание `v_19_5_patch` не открываем. На кластере это Helm-релиз `mk8s-v-19-3-patch`, файл `service/runners/templates/v_19_3_patch.yaml`: патч тот же, что у `v_18_10_patch`.

## Нативные секции

Helm-релизы `v_18_10_native` и `v_19_5_native`. Отличается `image.tag`: `alpine-v18.10.1` и `alpine-v19.5.3`. Чарт `0.87.1` и `0.94.3`.

```yaml
image:
  tag: alpine-v18.10.1
runners:
  executor: kubernetes
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine:3.20"
        [runners.kubernetes.build_container_security_context.seccomp_profile]
          type = "RuntimeDefault"
        [runners.kubernetes.build_container_security_context.app_armor_profile]
          type = "RuntimeDefault"
```

## Патч и аннотация

Helm-релиз `v_18_10_patch`. Чарт `0.87.1`, образ `alpine-v18.10.1`.

```yaml
image:
  tag: alpine-v18.10.1
runners:
  executor: kubernetes
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
```

## Что в контейнере build

| Под задания | Что записано |
| --- | --- |
| 18.10 native | только `capabilities.drop: NET_RAW` |
| 18.10 patch | `capabilities.drop: NET_RAW`, `seccompProfile: RuntimeDefault`, аннотация AppArmor `runtime/default` и поле `appArmorProfile: RuntimeDefault` |
| 19.5.3 native | `capabilities.drop: NET_RAW`, `seccompProfile` и `appArmorProfile`: `RuntimeDefault`. Аннотации нет |

На 18.10 нативные секции до контейнера не доходят. Патч записывает `seccompProfile`. Аннотацию AppArmor API переносит в поле `appArmorProfile`. На 19.5.3 те же профили приходят из нативных секций полями `securityContext`. `capabilities.drop: NET_RAW` стоит во всех трёх подах: это значение чарта.
