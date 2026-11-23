# Службы стенда

Перед этим слоем GitLab и кластер k8s уже должны быть подняты. Сейчас в нём один каталог, `runners`: группа `stand`, проект кластера и шесть Helm-релизов GitLab Runner. Проект k3s — `stand/stand-k3s`, префикс тегов `k3s_`. Проект управляемого кластера — `stand/stand-mk8s`, префикс `mk8s_`. На одном GitLab это один запуск: оба проекта и двенадцать Helm-релизов. Пользователь `terraform` выпускает токен и не владеет проектами лично. Задания и манифест `procMount` относятся к слою `app`. Файл заданий нужно отправить в проект GitLab. Манифест нужно применить в кластер.

Каталог `runners` читает путь к kubeconfig и адрес GitLab. Оба файла пишет каталог `base/yandex-mk8s`: `kubeconfig/k3s.kubeconfig` для узла k3s на машине GitLab и `kubeconfig/mk8s.kubeconfig` для управляемого кластера.

Состояние Terraform локальное, файл `terraform.tfstate` в каталоге `service/runners`.

## Перед запуском

Перед запуском GitLab уже должен отвечать по HTTP или HTTPS. Узлы k3s и управляемого кластера должны быть в состоянии Ready.

Публичный адрес GitLab нужно прочитать из каталога `base/yandex-mk8s`, в сеансе, где уже выполнен `source .tfenv`. Это выход `gitlab_public_ip`.

```bash
cd base/yandex-mk8s
source .tfenv
terraform output -raw gitlab_public_ip
```

В каталоге `service/runners` нужно скопировать `.tfenv.example` в `.tfenv`. В `TF_VAR_gitlab_public_ip` нужно записать публичный адрес GitLab. В `TF_VAR_k3s_kubeconfig_path` и `TF_VAR_mk8s_kubeconfig_path` нужно записать пути к kubeconfig. Пустая строка оставляет этот кластер без проекта и Helm-релизов. Имя GitLab повторно записывать не нужно: его подставляет уже выполненный `source` файла `.tfenv` каталога `base/yandex-mk8s`, переменная `TF_VAR_gitlab_domain`.

```bash
cd ../../service/runners
cp .tfenv.example .tfenv
```

В скопированном файле пустой адрес GitLab нужно заменить на выход команды выше. Пути к kubeconfig в `.tfenv.example` уже указывают на файлы `base/yandex-mk8s`. Команду `source` ниже нужно выполнить из этого же каталога: тогда `$PWD` указывает на `service/runners`.

```bash
export TF_VAR_gitlab_public_ip="<выход gitlab_public_ip>"
export TF_VAR_k3s_kubeconfig_path="$PWD/../../base/yandex-mk8s/kubeconfig/k3s.kubeconfig"
export TF_VAR_mk8s_kubeconfig_path="$PWD/../../base/yandex-mk8s/kubeconfig/mk8s.kubeconfig"
```

В том же сеансе, из каталога `service/runners`:

```bash
source .tfenv
```

### kubeconfig

Каталог `base/yandex-mk8s` при применении пишет `base/yandex-mk8s/kubeconfig/k3s.kubeconfig` и `base/yandex-mk8s/kubeconfig/mk8s.kubeconfig`. Из `service/runners` это `$PWD/../../base/yandex-mk8s/kubeconfig/k3s.kubeconfig` и `$PWD/../../base/yandex-mk8s/kubeconfig/mk8s.kubeconfig`.

Нужны Terraform 1.9 или новее и закрытый ключ `~/.ssh/id_ed25519`. Флаг `TF_VAR_gitlab_external_enabled` по умолчанию выключен. Этим ключом программа каталога входит на машину GitLab по `TF_VAR_gitlab_public_ip` и выпускает токен пользователю из `TF_VAR_gitlab_username`. По умолчанию это `terraform`. Пользователь — администратор. Пароль его входа не сохраняется. Пароль пользователя root в GitLab для выпуска токена не нужен. Флаг `TF_VAR_gitlab_user_create_enabled` по умолчанию включён: пользователь создаётся, если его ещё нет. Выключенный флаг оставляет создание вызывающему: пользователь с этим именем уже должен быть в GitLab.

Включённый `TF_VAR_gitlab_external_enabled` подключает уже существующий GitLab. Программа на машину не заходит и пользователя не создаёт. В `TF_VAR_gitlab_token` нужно записать уже выпущенный токен с областью `api`. В `TF_VAR_gitlab_base_url` нужно записать адрес API этого GitLab, с суффиксом `/api/v4`. Имя без этого суффикса должно открываться с подов Runner. Проекты создаются в группе `stand`: `stand-k3s` и `stand-mk8s`, по заполненному пути kubeconfig. Если проект уже есть в другом состоянии, apply останавливается.

## Применение

```bash
terraform init
terraform apply
```

Один запуск создаёт проект, шесть Runner и шесть Helm-релизов. Токен пользователя программа записывает на машине GitLab в `/srv/gitlab/terraform-pat` с правами `600`. Повторный запуск читает этот файл и новый токен не выпускает. Если в файле ещё лежит токен root, запуск отзывает его и записывает токен заданного пользователя. Токен этого пользователя и токены Runner остаются в локальном состоянии каталога.
