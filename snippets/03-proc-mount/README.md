# Листинг /proc при Default и Unmasked

## Что проверяем

Два пода. У `proc-mount-default` поле `hostUsers` не задано, `procMount: Default`. У `proc-mount-unmasked` заданы `hostUsers: false` и `procMount: Unmasked`. Без `hostUsers: false` API отклоняет `Unmasked`. Поле `hostUsers` относится к поду, поэтому поды разделены.

Команда: `ls -ld` семи имён. Сначала под `proc-mount-default`, затем `proc-mount-unmasked`. Содержимое `kcore` не читаем. В кадр не берём весь `/proc`: остальные имена совпадают. На маску смотрим по типу файла.

При `Default` семь записей закрыты. `interrupts`, `keys`, `kcore`, `latency_stats` и `timer_list` видны как символьное устройство `1,3`. `acpi` и `scsi` — каталоги `drwxrwxrwt` размером 40. Владелец записей — `root`.

При `Unmasked` это обычные файлы и каталоги. Размер `kcore` — `72057594021171200`. Владелец записей — `nobody`.

## Зачем

Показать, что маска по умолчанию закрывает записи ядра. `Unmasked` снимает маску и список только для чтения. Отказа сборки, который отличал бы `Default` от `Unmasked`, на стенде нет: `mount` и `pivot_root` отказывают одинаково, capability `SYS_ADMIN` в под не входит. Показ остаётся листингом.

Сниппет прогнан 20 ноября 2026 на k3s `v1.34.12+k3s1`, пространство имён `default`. На управляемом кластере под с `hostUsers: false` остаётся в `Pending`: snapshotter `overlayfs` не поддерживает idmap-монтирование.
