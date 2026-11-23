# Стенд демонстрации

Репозиторий описывает стенд мастер-класса. Команды запуска и состав машин записаны в `README.md` соответствующего каталога. Применение конфигурации выполняется отдельным шагом.

## Состав

| Каталог | Назначение |
| --- | --- |
| `base` | Облачные ресурсы. Каталог `base/yandex-mk8s` описывает контур в Yandex Cloud: машина GitLab с GitLab CE и одним узлом k3s, отдельно кластер Managed Kubernetes. Подсеть `stand` создаёт каталог. Имя сети и зону задаёт `.tfenv`. |
| `service` | Службы на уже поднятых GitLab и кластере. Каталог `service/runners` создаёт группу `stand`, проекты и Helm-релизы Runner. |
| `app` | Задания показа. Файлы `k3s.gitlab-ci.yml` и `mk8s.gitlab-ci.yml` отправляют копией в проекты GitLab. |
| `snippets` | Примеры манифестов и записанный вывод показа. |

Где состав узла не важен, кластер называется k8s.

## Порядок развёртывания

Команды каждого шага записаны в `README.md` указанного каталога.

1. `base/yandex-mk8s`. Нужно заполнить `.tfenv` из `.tfenv.example`. До `terraform apply` нужно зарезервировать публичный адрес GitLab и создать запись `A` имени из `gitlab_domain`. К моменту `terraform apply` имя должно резолвиться в этот адрес. Затем нужно выполнить `terraform apply`. Применение поднимает машину GitLab, узел k3s и кластер Managed Kubernetes и записывает `kubeconfig/k3s.kubeconfig` и `kubeconfig/mk8s.kubeconfig`.
2. `service/runners`. Перед этим шагом GitLab должен отвечать, узлы кластеров должны быть в состоянии Ready. Нужно записать в `service/runners/.tfenv` адрес GitLab и пути к kubeconfig из шага 1. Затем нужно выполнить `terraform apply`. Применение создаёт в GitLab группу `stand`, проекты и деплоит Helm-релизы GitLab Runner. Пространство имён `gitlab-runner` создаёт чарт. На управляемом кластере то же применение ставит чарт `profiles`: ConfigMap и DaemonSet `stand-buildkit-profiles` доставляют профили seccomp и AppArmor в это пространство имён.
3. `app`. Перед отправкой проекты `stand/stand-k3s` и `stand/stand-mk8s` уже должны существовать. Нужно положить копии `k3s.gitlab-ci.yml` и `Dockerfile` во временный каталог вне репозитория стенда и отправить их в `stand/stand-k3s`. Копии `mk8s.gitlab-ci.yml` и `Dockerfile` нужно отправить в `stand/stand-mk8s`. В проекте GitLab файл заданий называется `.gitlab-ci.yml`. Теги в файлах уже содержат префикс кластера.

## Helm-релизы

Каталог `service/runners` создаёт проект и Helm-релизы того кластера, для которого в `service/runners/.tfenv` задан путь к kubeconfig: `TF_VAR_k3s_kubeconfig_path` или `TF_VAR_mk8s_kubeconfig_path`. Образец — `service/runners/.tfenv.example`. Пустая строка оставляет этот кластер без проекта и Helm-релизов.

| Кластер | Проект | Префикс |
| --- | --- | --- |
| k3s на машине GitLab | `stand/stand-k3s` | `k3s_` |
| Управляемый Kubernetes | `stand/stand-mk8s` | `mk8s_` |

Helm-релизов показа шесть: пары `native` и `patch` для 18.10 и 19.5, а также `v_19_5_unconfined` и `v_19_5_runtime_default` на нативных секциях. Helm-релизов сборки BuildKit два: `v_19_5_buildkit_rootless` и `v_19_5_buildkit_privileged`.

## Задания

`k3s.gitlab-ci.yml` и `mk8s.gitlab-ci.yml` содержат шесть ручных заданий показа и два ручных задания сборки BuildKit. Имя задания совпадает с именем Helm-релиза. Теги в `k3s.gitlab-ci.yml` начинаются с `k3s_`, в `mk8s.gitlab-ci.yml` — с `mk8s_`.

## Примеры

| Каталог | Тема |
| --- | --- |
| `snippets/01-runner-version` | Доставка настройки до контейнера `build` |
| `snippets/02-hostpid-read-env` | Чтение переменныхокружения соседнего пода |
| `snippets/03-proc-mount` | Листинг `/proc` при `Default` и `Unmasked` |
| `snippets/04-capabilities-chown` | Смена владельца файла без capability `CAP_CHOWN` и с ней |
| `snippets/05-file-capabilities` | Файловые capabilities |
| `snippets/06-seccomp-pivot-root` | Отказ seccomp `RuntimeDefault` на `unshare` |
| `snippets/07-apparmor-mount` | Отказ AppArmor `RuntimeDefault` на `mount` |
| `snippets/08-localhost-profiles` | Доставка профилей `Localhost` |
| `snippets/09-buildkit` | Сборщик BuildKit |
| `snippets/experiments` | Различные эксперименты |
