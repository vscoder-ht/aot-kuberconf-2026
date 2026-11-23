# Финальный кейс: сборщик BuildKit

Два Helm-релиза на управляемом кластере. Ближе к чек-листу пода Helm-релиз rootless. Helm-релиз privileged задаёт `privileged: true` и секции профилей `Localhost`. Остальные поля чек-листа не задаёт. Среда выполнения при `privileged: true` профили seccomp и AppArmor не применяет.

Прогон 20 ноября 2026. Оба задания на mk8s завершились успехом: шаг `RUN echo ok` прошёл. Образы — `moby/buildkit:v0.35.1` и `moby/buildkit:v0.35.1-rootless`.

Файлы каталога:

- [values-rootless.yaml](values-rootless.yaml) и [values-privileged.yaml](values-privileged.yaml) — примеры values Helm-релизов
- [profile.json](profile.json) — профиль seccomp
- [seccomp-daemonset.yaml](seccomp-daemonset.yaml) — доставка профиля seccomp на узел
- [apparmor-daemonset.yaml](apparmor-daemonset.yaml) — загрузка профиля AppArmor в ядро
- [pod.yaml](pod.yaml) — под проверки профиля
- [snippet.md](snippet.md) — команды
- [output.md](output.md) — запись прогона профиля

## Что собирает задание

Задание GitLab запускает `buildctl-daemonless.sh` и собирает `Dockerfile` из корня проекта.

- В `Dockerfile` одна инструкция: `RUN echo ok`.
- Секрета сборки в файле нет.
- Образ и флаг демона задаёт задание.
- Под контейнера `build` задают values Helm-релиза. Задание эти values не меняет.

| Helm-релиз | Образ | `BUILDKITD_FLAGS` |
| --- | --- | --- |
| rootless | `moby/buildkit:v0.35.1-rootless` | `--oci-worker-no-process-sandbox` |
| privileged | `moby/buildkit:v0.35.1` | пустая строка |

На mk8s без `--oci-worker-no-process-sandbox` шаг `RUN` не монтирует `/proc`. С образом privileged этот флаг не используют.

У rootless `allow_privilege_escalation` равен `true`. Сборщик сам поднимает user namespace. Для карты идентификаторов нужны `newuidmap` и `newgidmap`.

## Чек-лист пода

| Пункт | rootless | privileged |
| --- | --- | --- |
| `privileged: false` | `false` | `true` |
| `runAsNonRoot: true` | `true`, uid и gid `1000` | ключа нет |
| `allowPrivilegeEscalation: false`, кроме сборщика со своим user namespace | `true` | ключа нет |
| `drop: [ALL]`, обратно только нужные | те же семь прав | ключа нет |
| `hostUsers: false`, если версии позволяют | ключа нет | ключа нет |
| `procMount: Default` | ключа нет | ключа нет |
| seccomp `RuntimeDefault` или свой `Localhost` | `Localhost`, `stand-buildkit.json` | секция `Localhost`, `stand-buildkit.json` |
| AppArmor — свой `Localhost` | `Localhost`, `stand-buildkit` | секция `Localhost`, `stand-buildkit` |
| `automountServiceAccountToken: false` | ключа нет | ключа нет |
| секрет сборки `--mount=type=secret` | в `Dockerfile` нет | в `Dockerfile` нет |

`hostUsers` в успешный прогон не входил. Отдельный замер на этом кластере: под с `hostUsers: false` не создаёт песочницу, snapshotter `overlayfs` не поддерживает idmap.

## Профиль seccomp

Основа [profile.json](profile.json) — `RuntimeDefault` containerd 2.2.1 для amd64. К ней добавлены:

- `mount`, `umount2`, `pivot_root`
- `unshare` и `setns` — своё пространство сборщика
- `sethostname` и `setdomainname`
- `clone`

У `clone` в [profile.json](profile.json) нет условия на флаги: вызов разрешён и с флагами нового пространства. Прогон, где `clone` был разрешён только без этих флагов, остановился на `fork/exec /proc/self/exe`: `operation not permitted`. Без `sethostname` и `setdomainname` сборка останавливается в `runc` на `sethostname: operation not permitted`.

Имя файла на узле — `buildkit.json`.

- [seccomp-daemonset.yaml](seccomp-daemonset.yaml) копирует файл в `/var/lib/kubelet/seccomp`.
- ConfigMap собирается из `profile.json`.
- Команды — в [snippet.md](snippet.md).

[pod.yaml](pod.yaml) повторяет контекст Helm-релиза rootless и задаёт профиль seccomp `buildkit.json`. Сборка в этом поде — `FROM alpine:3.20` и `RUN echo ok`, флаг демона `--oci-worker-no-process-sandbox`.

Прогон seccomp 23 ноября 2026 с именем `buildkit.json` записан в [output.md](output.md): при снятом AppArmor под завершился успехом. Под проверки по-прежнему задаёт `buildkit.json`. Helm-релиз rootless на mk8s задаёт отдельный профиль `stand-buildkit.json`. Его доставляет DaemonSet `stand-buildkit-profiles` в пространстве имён `gitlab-runner`.

## Профиль AppArmor

Тот же день, тот же под. Поле seccomp не менялось.

`RuntimeDefault` под поднимает, сборку нет. `rootlesskit` останавливается на `failed to share mount point: /: permission denied`. В шаблоне containerd стоит `deny mount`.

[apparmor-daemonset.yaml](apparmor-daemonset.yaml) загружает профиль `buildkit` вызовом `apparmor_parser`. Основа — тот же шаблон. Вместо `deny mount` стоят `mount` и `pivot_root`. Имя в ядре — `buildkit`. У пода проверки поле `appArmorProfile.type` равно `Localhost`.

Повторный прогон с этим профилем завершился успехом: шаг `RUN echo ok` прошёл, в журнале есть `BUILD_OK`. Под проверки по-прежнему задаёт профиль `buildkit`. Helm-релиз rootless на mk8s задаёт отдельное имя `stand-buildkit`. Тот же DaemonSet загружает его в ядро.

## Где

Проект GitLab: https://gitlab.example.com/stand/stand-mk8s

| | rootless | privileged |
| --- | --- | --- |
| Задание в `app/mk8s.gitlab-ci.yml` | `v_19_5_buildkit_rootless` | `v_19_5_buildkit_privileged` |
| Тег в проекте mk8s | `mk8s_v_19_5_buildkit_rootless` | `mk8s_v_19_5_buildkit_privileged` |
| Helm | `mk8s-v-19-3-buildkit-rootless` | `mk8s-v-19-3-buildkit-privileged` |
| Values | `service/runners/templates/v_19_3_buildkit_rootless.yaml` | `service/runners/templates/v_19_3_buildkit_privileged.yaml` |

Чарт обоих Helm-релизов — `gitlab-runner` `0.94.3`. Образ менеджера Runner — `alpine-v19.5.3`. Пространство имён — `gitlab-runner`.

- В `app/mk8s.gitlab-ci.yml` теги заданий уже начинаются с `mk8s_`. Имена заданий без префикса.
- `gitlabUrl` и `runnerToken` подставляет Terraform. В примеры values они не входят.
- `Dockerfile` и `mk8s.gitlab-ci.yml` лежат в `vsc-kuberconf-aot-2026-stand/app`. В проект GitLab нужно отправить копии этих файлов. В проекте файл заданий называется `.gitlab-ci.yml`. Перед отправкой проект уже должен существовать.

## Как

Оба задания ручные. Общий script:

```yaml
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --output type=local,dest=./out
```

У образа свой `entrypoint`. В задании он пустой, иначе script не стартует.

| Каталог | Helm-релиз | Тип |
| --- | --- | --- |
| `/home/user/.local/share/buildkit` | rootless | `emptyDir` |
| `/var/lib/buildkit` | privileged | `emptyDir` |
| `/tmp` | оба | `emptyDir` |

В `/tmp` лежат `builds_dir`, журналы и script.

## Примеры values

Фрагменты ниже повторяют `config.toml` Helm-релизов mk8s. Полные файлы — в `templates`. Рядом лежат [values-rootless.yaml](values-rootless.yaml) и [values-privileged.yaml](values-privileged.yaml).

### rootless

```yaml
image:
  tag: alpine-v19.5.3
runners:
  executor: kubernetes
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine:3.20"
        privileged = false
        builds_dir = "/tmp/builds"
        logs_base_dir = "/tmp"
        scripts_base_dir = "/tmp"

        [runners.kubernetes.pod_security_context]
          fs_group = 1000

        [runners.kubernetes.build_container_security_context]
          run_as_non_root = true
          run_as_user = 1000
          run_as_group = 1000
          allow_privilege_escalation = true

          [runners.kubernetes.build_container_security_context.capabilities]
            drop = ["ALL"]
            add = ["CHOWN", "DAC_OVERRIDE", "FOWNER", "FSETID", "SETGID", "SETUID", "SETFCAP"]

          [runners.kubernetes.build_container_security_context.seccomp_profile]
            type = "Localhost"
            localhost_profile = "stand-buildkit.json"

          [runners.kubernetes.build_container_security_context.app_armor_profile]
            type = "Localhost"
            localhost_profile = "stand-buildkit"

        [[runners.kubernetes.volumes.empty_dir]]
          name = "buildkit-state"
          mount_path = "/home/user/.local/share/buildkit"

        [[runners.kubernetes.volumes.empty_dir]]
          name = "buildkit-tmp"
          mount_path = "/tmp"
```

### privileged

```yaml
image:
  tag: alpine-v19.5.3
runners:
  executor: kubernetes
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine:3.20"
        privileged = true
        builds_dir = "/tmp/builds"
        logs_base_dir = "/tmp"
        scripts_base_dir = "/tmp"

        [[runners.kubernetes.volumes.empty_dir]]
          name = "buildkit-lib"
          mount_path = "/var/lib/buildkit"

        [[runners.kubernetes.volumes.empty_dir]]
          name = "buildkit-tmp"
          mount_path = "/tmp"
```
