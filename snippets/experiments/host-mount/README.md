# Монтирование каталога узла

## Что проверяем

Три пода на одном узле. Секрета нет.

`hostpid-mount-nopriv` запускается с `hostPID: true`, `privileged: false` и `runAsUser: 0`. Из контейнера выполняется `mount`.

`hostpid-mount-priv` запускается с `hostPID: true`, `privileged: true` и `runAsUser: 0`. Из контейнера монтируется корневой диск узла `/dev/vda1`.

`hostpath-mount` запускается с `privileged: false` и `runAsUser: 0`. Каталог `/etc` узла подключает kubelet томом `hostPath` в путь `/host-etc`.

Во всех трёх подах проверяется доступ к файлу владельца `root` с режимом `0600`. Содержимое файла не снимается.

## Результат

Без `privileged` вызов `mount` из контейнера не проходит. Устройства `/dev/vda1` в контейнере нет. Переход по `/proc/1/root` даёт `Permission denied`. `CapEff` равен `00000000a80425fb`.

С `privileged: true` процесс идёт от uid `0`, `CapEff` равен `000001ffffffffff`, AppArmor — `unconfined`. `mount -t ext4 /dev/vda1` завершается с кодом 0. Файл `root` с режимом `0600` на этом диске читается. Привязка `/proc/1/root/etc` через `mount -o bind` даёт `Invalid argument`.

Том `hostPath` kubelet монтирует без `privileged`. В `hostpath-mount` тот же файл `root` с режимом `0600` читается. `CapEff` равен `00000000a80425fb`.
