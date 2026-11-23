# privileged и hostUsers: false

Прогон 22 ноября 2026 на k3s `v1.34.12+k3s1`. Вывод — [output.md](output.md). В показ не входит.

## Что проверяем

Под `priv-userns` запускается с `privileged: true`, `hostUsers: false` и `runAsUser: 0`. Поле `hostPID` не задано: вместе с `hostUsers: false` его задать нельзя.

Из контейнера выполняется `mount -t ext4 /dev/vda1 /tmp/hostroot`. Та же команда в проверке [host-mount](../host-mount/) у пода `hostpid-mount-priv` проходит: там `privileged: true`, поле `hostUsers` не задано.

Секрета нет. Содержимое файлов диска не снимается.

## Результат

Под дошёл до `Running`. Внутри `id` показывает uid `0`. `CapEff` и `CapBnd` равны `000001ffffffffff`. AppArmor — `unconfined`.

Файл `/proc/self/uid_map` содержит `0 4185784320 65536`: первое число — начало внутри контейнера, второе — начало на узле, третье — длина. На узле процесс идёт от `4185784320`.

Устройство `/dev/vda1` в контейнере есть. Владелец — `nobody`. Команда `mount` завершается с кодом `1`: `permission denied (are you root?)`. Точка `/tmp/hostroot` в `mountinfo` не появляется.

## Где запускать

Манифест рассчитан на k3s. На управляемом кластере под с `hostUsers: false` до `Running` не доходит: snapshotter `overlayfs` не поддерживает idmap.
