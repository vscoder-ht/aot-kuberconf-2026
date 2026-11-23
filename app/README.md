# Задания показа

Каталог `app` содержит два файла заданий GitLab и `Dockerfile` сборки BuildKit. Каталог входит в репозиторий стенда. Репозиторий Git внутри него не создаётся.

## Состав

| Файл | Назначение |
| --- | --- |
| `k3s.gitlab-ci.yml` | Задания проекта `stand/stand-k3s`. Теги с префиксом `k3s_` |
| `mk8s.gitlab-ci.yml` | Задания проекта `stand/stand-mk8s`. Теги с префиксом `mk8s_` |
| `Dockerfile` | Образ сборки: базовый образ `alpine:3.20`, шаг `RUN echo ok` |

Имена заданий в обоих файлах совпадают. Теги различаются префиксом кластера. Задание `.buildkit` GitLab не запускает: имя начинается с точки. Два задания сборки берут из него образ и шаг.

| Задание | Шаг |
| --- | --- |
| `v_18_10_native`, `v_18_10_patch`, `v_19_5_native`, `v_19_5_patch`, `v_19_5_unconfined`, `v_19_5_runtime_default` | `sleep infinity` |
| `v_19_5_buildkit_privileged`, `v_19_5_buildkit_rootless` | сборка `Dockerfile` |

## Сборка BuildKit

Сборка читает `Dockerfile` из корня проекта. Образ задаёт переменная `BUILDKIT_IMAGE`, флаги демона — `BUILDKITD_FLAGS`. Обе переменные можно заменить в форме запуска задания. Pod контейнера `build` задают values Helm-релиза.

| Задание | `BUILDKIT_IMAGE` | `BUILDKITD_FLAGS` |
| --- | --- | --- |
| `v_19_5_buildkit_privileged` | `moby/buildkit:v0.35.1` | пустая строка |
| `v_19_5_buildkit_rootless` | `moby/buildkit:v0.35.1-rootless` | `--oci-worker-no-process-sandbox` |

## Отправка

Перед отправкой проекты `stand/stand-k3s` и `stand/stand-mk8s` уже должны существовать. Их создаёт каталог `service/runners`. Ветка `main` защищена: отправлять может администратор инстанса. Пользователь `terraform` — администратор. Его токен записан на машине GitLab в `/srv/gitlab/terraform-pat`.

Команды нужно выполнить из корня репозитория стенда. Адрес GitLab — `https://` и значение `TF_VAR_gitlab_domain`. Копии лежат во временных каталогах вне репозитория стенда. В проекте GitLab файл заданий называется `.gitlab-ci.yml`.

```bash
cd base/yandex-mk8s
source .tfenv
export GITLAB_HOST=$(terraform output -raw gitlab_public_ip)
cd ../..
export STAND_ROOT=$PWD
export GITLAB_TOKEN=$(ssh -o IdentitiesOnly=yes -o BatchMode=yes -i ~/.ssh/id_ed25519 ubuntu@$GITLAB_HOST sudo cat /srv/gitlab/terraform-pat)
```

Проект `stand/stand-k3s`:

```bash
cd $STAND_ROOT
export K3S_DIR=$(mktemp -d)
cp app/k3s.gitlab-ci.yml $K3S_DIR/.gitlab-ci.yml
cp app/Dockerfile $K3S_DIR/
cd $K3S_DIR
git init -b main
git add .gitlab-ci.yml Dockerfile
git -c user.name=terraform -c user.email=terraform@stand.invalid commit -m "Add stand jobs"
git remote add origin https://terraform:$GITLAB_TOKEN@$TF_VAR_gitlab_domain/stand/stand-k3s.git
git push -u origin main
```

Проект `stand/stand-mk8s`:

```bash
cd $STAND_ROOT
export MK8S_DIR=$(mktemp -d)
cp app/mk8s.gitlab-ci.yml $MK8S_DIR/.gitlab-ci.yml
cp app/Dockerfile $MK8S_DIR/
cd $MK8S_DIR
git init -b main
git add .gitlab-ci.yml Dockerfile
git -c user.name=terraform -c user.email=terraform@stand.invalid commit -m "Add stand jobs"
git remote add origin https://terraform:$GITLAB_TOKEN@$TF_VAR_gitlab_domain/stand/stand-mk8s.git
git push -u origin main
```
