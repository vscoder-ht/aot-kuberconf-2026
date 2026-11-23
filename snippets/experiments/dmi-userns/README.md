# Сведения узла и hostUsers

Прогон 22 ноября 2026 на k3s `v1.34.12+k3s1` и на управляемом кластере Kubernetes `v1.35.1`. Вывод — [output.md](output.md). В показ не входит.

## Что проверяем

Два пода от uid `0`. Поле `privileged` не задано. Секрета нет. Содержимое файлов не снимается: проверяется только открытие.

`info-host`: поле `hostUsers` не задано. Этот под запускается и на управляемом кластере.

`info-userns`: `hostUsers: false`.

Смотрим файлы режима `0400` со сведениями об оборудовании узла и `/proc/slabinfo`. Рядом — файлы режима `0444`, которые открываются в обоих подах.

## Результат

Оба пода дошли до `Running`.

Без `hostUsers` открываются `/sys/class/dmi/id/product_uuid`, `product_serial`, `board_serial`, `chassis_serial` и `/proc/slabinfo`. В `ls` владелец — `root`, режим `0400` у файлов DMI и у `slabinfo`.

С `hostUsers: false` те же файлы дают `Permission denied`. В `ls` владелец — `nobody`, режим тот же.

В обоих подах на k3s открываются `/proc/version`, `/proc/cmdline`, `/proc/cpuinfo`, `/sys/class/dmi/id/sys_vendor` и `product_name`.

На управляемом кластере под `info-host` дошёл до `Running`. Открываются те же файлы, что и у `info-host` на k3s: серийные номера DMI, `/proc/slabinfo` и файлы режима `0444`.

## Где запускать

Оба пода рассчитаны на k3s. На управляемом кластере под с `hostUsers: false` до `Running` не доходит: snapshotter `overlayfs` не поддерживает idmap. Под `info-host` на управляемом кластере запускается.
