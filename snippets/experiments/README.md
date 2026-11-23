# Проверки чтения окружения

Исходный кейс лежит в каталоге [02-hostpid-read-env](../02-hostpid-read-env/). В каталогах этих проверок свой Secret и свои поды. У читающего пода задан `hostPID: true`. Командная строка чужого процесса читается во всех проверках. Файл `/proc/<pid>/environ` открывается при совпадении uid.

| Каталог | uid пода с секретом | uid читателя | privileged читателя | `/proc/<pid>/environ` |
| --- | --- | --- | --- | --- |
| [исходный кейс](../02-hostpid-read-env/) | 0 | 0 | не задан | читается, в файле `password` секрета |
| [reader-uid-1000](reader-uid-1000/) | 0 | 1000 | не задан | `Permission denied` |
| [both-uid-1000](both-uid-1000/) | 1000 | 1000 | не задан | читается, в файле `password` секрета |
| [different-uid](different-uid/) | 1000 | 2000 | не задан | `Permission denied` |
| [different-uid-privileged](different-uid-privileged/) | 1000 | 2000 | `true`, `CapEff` `0000000000000000` | `Permission denied` |
| [reader-uid0](reader-uid0/) | 1000 | 0 | `false`, `CapEff` `00000000a80425fb` | `Permission denied` |

## Монтирование каталога узла

Проверка [host-mount](host-mount/) не читает окружение процессов. Секрета нет. Сравниваются вызов `mount` из контейнера и том `hostPath`, который монтирует kubelet.

| Под | Способ | privileged | Файл `root`, режим `0600` |
| --- | --- | --- | --- |
| `hostpid-mount-nopriv` | `mount` из контейнера | `false`, `CapEff` `00000000a80425fb` | устройства узла нет, `mount` не проходит |
| `hostpid-mount-priv` | `mount -t ext4 /dev/vda1` | `true`, `CapEff` `000001ffffffffff` | читается |
| `hostpath-mount` | том `hostPath` `/etc` | `false`, `CapEff` `00000000a80425fb` | читается |

## Общий каталог и hostUsers

Проверка [shared-uid](shared-uid/) не читает окружение процессов. Прогон 22 ноября 2026 на k3s `v1.34.12+k3s1`. Обе пары читают файл режима `0600`. На узле оба файла принадлежат uid `1000`. У пары с `hostUsers: false` процессы на узле идут от `4141089768` и `1987118056`.

## Файл root и hostUsers: false

Проверка [rootfile-userns](rootfile-userns/) не читает окружение процессов. Прогон 22 ноября 2026 на k3s `v1.34.12+k3s1`. Файл на узле принадлежит uid `0`, режим `0600`. Под с `hostUsers: false` и `runAsUser: 0` его читает. Под с `runAsUser: 1000` получает `Permission denied`.

## privileged и hostUsers: false

Проверка [priv-userns](priv-userns/) не читает окружение процессов. Прогон 22 ноября 2026 на k3s `v1.34.12+k3s1`. Под с `privileged: true` и `hostUsers: false` доходит до `Running`. `CapEff` равен `000001ffffffffff`. Команда `mount -t ext4 /dev/vda1` возвращает `permission denied`.

## Сведения узла и hostUsers

Проверка [dmi-userns](dmi-userns/) не читает окружение процессов. Прогон 22 ноября 2026 на k3s `v1.34.12+k3s1`. Без `hostUsers` под от uid `0` открывает серийные номера DMI и `/proc/slabinfo`. С `hostUsers: false` те же файлы дают `Permission denied`. На управляемом кластере Kubernetes `v1.35.1` под `info-host` открывает те же файлы. Содержимое этих файлов печатает [node-info](node-info/).

## allowPrivilegeEscalation

Проверка [ape-setuid](ape-setuid/) не читает окружение процессов. Прогон 22 ноября 2026 на управляемом кластере, Kubernetes `v1.35.1`. При `allowPrivilegeEscalation: true` процесс от uid `1000` читает файл root. При `false` ядро возвращает `Permission denied`.
