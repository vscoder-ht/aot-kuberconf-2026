# GitLab Runner

Один запуск создаёт группу `stand` и, для каждого заполненного kubeconfig, проект, шесть Helm-релизов показа и два Helm-релиза сборки BuildKit. Пустая строка оставляет этот кластер без проекта и Helm-релизов. Задания относятся к слою `app`.

## Состав

| Файл | Назначение |
| --- | --- |
| `main.tf` | Группа, проекты и защита ветки `main` |
| `runners.tf` | Runner и Helm-релизы, по ресурсу на Helm-релиз и кластер |
| `variables.tf` | Входные переменные |
| `versions.tf` | Terraform `>= 1.9`, провайдеры `gitlabhq/gitlab` `~> 19.5` и `hashicorp/helm` `~> 3.3` |
| `.terraform.lock.hcl` | Зафиксированные версии провайдеров |
| `.tfenv.example` | Образец переменных окружения. Рабочая копия — `.tfenv` |
| `gitlab-token.sh` | Выпуск токена доступа на машине GitLab стенда |
| `templates/*.yaml` | Values одного Helm-релиза. Адрес GitLab подставляется при применении |
| `profiles/` | Локальный чарт: профили seccomp и AppArmor сборки и DaemonSet доставки на mk8s |

Вне репозитория остаются `.tfenv`, kubeconfig и файлы стейта Terraform, так как в них лежат токен доступа и токены Runner.

Имена Helm и тега показаны на Helm-релизе `v_18_10_native`. Для каждого из шести Helm-релизов правило то же, тег один.

```text
группа stand
├── проект stand/stand-k3s                 TF_VAR_k3s_kubeconfig_path
│   └── шесть Helm-релизов, пространство имён gitlab-runner
│       ├── Helm-релиз v_18_10_native
│       ├── Helm       k3s-v-18-10-native
│       └── тег        k3s_v_18_10_native
└── проект stand/stand-mk8s                TF_VAR_mk8s_kubeconfig_path
    └── шесть Helm-релизов, пространство имён gitlab-runner
        ├── Helm-релиз v_18_10_native
        ├── Helm       mk8s-v-18-10-native
        └── тег        mk8s_v_18_10_native
```

| Helm-релиз | Чарт | Образ | Профили seccomp и AppArmor | `SYS_ADMIN` |
| --- | --- | --- | --- | --- |
| `v_18_10_native` | `0.87.1` | `alpine-v18.10.1` | нативные секции, оба `RuntimeDefault` | нет |
| `v_18_10_patch` | `0.87.1` | `alpine-v18.10.1` | seccomp `RuntimeDefault` патчем `pod_spec`, AppArmor аннотацией `runtime/default` | нет |
| `v_19_5_native` | `0.94.3` | `alpine-v19.5.3` | нативные секции, оба `RuntimeDefault` | нет |
| `v_19_3_patch` | `0.94.3` | `alpine-v19.5.3` | тот же патч, оба `RuntimeDefault` | нет |
| `v_19_3_unconfined` | `0.94.3` | `alpine-v19.5.3` | нативные секции, оба `Unconfined` | да |
| `v_19_3_runtime_default` | `0.94.3` | `alpine-v19.5.3` | seccomp `RuntimeDefault`, AppArmor `Unconfined` | да |

### Сборка BuildKit

Два Helm-релиза сборки стоят отдельно от шести Helm-релизов показа. На каждый кластер у релиза своя пара ресурсов `gitlab_user_runner.<префикс>_<ключ>` и `helm_release.<префикс>_<ключ>` и свой файл в `templates/`. Префикс k3s — `k3s`, префикс mk8s — `mk8s`. Чарт обоих — `0.94.3`, образ менеджера Runner — `alpine-v19.5.3`.

Имя Helm — префикс кластера и ключ, в ключе подчёркивания заменены дефисами. Тег — тот же ключ с префиксом `k3s_` или `mk8s_`.

| Ключ | Helm k3s | Helm mk8s |
| --- | --- | --- |
| `v_19_3_buildkit_rootless` | `k3s-v-19-3-buildkit-rootless` | `mk8s-v-19-3-buildkit-rootless` |
| `v_19_3_buildkit_privileged` | `k3s-v-19-3-buildkit-privileged` | `mk8s-v-19-3-buildkit-privileged` |

Pod контейнера `build` задаёт `config.toml` из файла values. Образ и `BUILDKITD_FLAGS` задаёт задание GitLab.

| Ключ | Файл values | Образ по умолчанию | `BUILDKITD_FLAGS` |
| --- | --- | --- | --- |
| `v_19_3_buildkit_rootless` | `templates/v_19_3_buildkit_rootless.yaml` | `moby/buildkit:v0.35.1-rootless` | `--oci-worker-no-process-sandbox` |
| `v_19_3_buildkit_privileged` | `templates/v_19_3_buildkit_privileged.yaml` | `moby/buildkit:v0.35.1` | пустая строка |

На mk8s оба Helm-релиза запрашивают профили `Localhost`: seccomp `stand-buildkit.json`, AppArmor `stand-buildkit`. На k3s у rootless остаются `Unconfined`, у privileged секции профилей нет.

Файлы профилей лежат в `profiles/`. Тот же `terraform apply`, что ставит Runner, ставит на mk8s чарт `profiles` релизом `stand-buildkit-profiles`. Чарт создаёт ConfigMap и DaemonSet `stand-buildkit-profiles` в пространстве имён `gitlab-runner`. DaemonSet копирует файл seccomp в `/var/lib/kubelet/seccomp` и загружает профиль AppArmor в ядро вызовом `apparmor_parser`.

Установщик вызывает `apparmor_parser` один раз при старте. В шаблон пода записана контрольная сумма файлов профиля. После правки файлов следующий `terraform apply` меняет аннотацию и перезапускает DaemonSet. Удаление релиза оставляет файл seccomp на узле и профиль AppArmor в ядре.

У контейнера с `privileged = true` среда выполнения профили seccomp и AppArmor не применяет. В Helm-релизе mk8s privileged секции профилей заданы, ограничение от них не включается.

## Создание и удаление

### Перед запуском

Перед запуском GitLab уже должен отвечать. Нужны Terraform 1.9 или новее и закрытый ключ `~/.ssh/id_ed25519`.

В том же сеансе сначала нужно выполнить `source` файла `.tfenv` каталога `base/yandex-mk8s`: оттуда берётся `TF_VAR_gitlab_domain`. Затем в этом каталоге нужно выполнить:

```bash
cp .tfenv.example .tfenv
source .tfenv
terraform init
```

Каталог `base/yandex-mk8s` при своём применении пишет оба kubeconfig в `base/yandex-mk8s/kubeconfig`. В `.tfenv.example` пути `TF_VAR_k3s_kubeconfig_path` и `TF_VAR_mk8s_kubeconfig_path` уже указывают на эти файлы.

### Применение

```bash
terraform apply
```

Пустой путь удаляет проект этого кластера и его Helm-релизы при следующем apply.

### Удаление

Нужна та же оболочка и те же пути kubeconfig. К этому моменту GitLab и API заполненных кластеров ещё должны отвечать. Каталог `base/yandex-mk8s` нужно удалить после этого каталога.

```bash
terraform destroy
```

Команда удаляет группу, оба проекта, защиту веток, Runner и Helm-релизы. Пользователь GitLab и файл `/srv/gitlab/terraform-pat` остаются на машине: их создаёт `gitlab-token.sh`.

## Нюансы

**Токен.** При выключенном `gitlab_external_enabled` скрипт входит на машину GitLab по SSH и выпускает токен пользователю из `gitlab_username`, по умолчанию `terraform`. Флаг `gitlab_user_create_enabled` по умолчанию включён и создаёт этого пользователя, если его ещё нет. Пользователь — администратор, пароль входа не сохраняется. Токен записывается в `/srv/gitlab/terraform-pat` с правами `600`. Повторный запуск читает этот файл. Включённый `gitlab_external_enabled` берёт готовый токен из `gitlab_token` и адрес API из `gitlab_base_url`.

**Проект.** Проекты создаются в группе `gitlab_group_path`. Runner зарегистрирован на свой проект, `untagged` выключен: он забирает задания этого проекта со своим тегом.

**Ветка `main`.** Push и merge разрешены администраторам инстанса, уровень `admin`. С GitLab 18 этот уровень нужно задать явно, иначе администраторы `root` и `terraform` не запускают конвейер с защищённой ветки.

**Провайдер.** После смены версии `gitlabhq/gitlab` нужно выполнить `terraform init -upgrade`.
