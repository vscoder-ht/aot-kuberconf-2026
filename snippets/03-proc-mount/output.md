Записанный вывод кейса procMount. Показывать, если стенд не отвечает.

Прогон 20 ноября 2026 на k3s `v1.34.12+k3s1`, пространство имён `default`.

```bash
$ kubectl exec proc-mount-default -- ls -ld /proc/interrupts /proc/keys /proc/kcore /proc/latency_stats /proc/timer_list /proc/acpi /proc/scsi
drwxrwxrwt    2 root     root            40 Nov 19 23:02 /proc/acpi
crw-rw-rw-    1 root     root        1,   3 Nov 19 23:02 /proc/interrupts
crw-rw-rw-    1 root     root        1,   3 Nov 19 23:02 /proc/kcore
crw-rw-rw-    1 root     root        1,   3 Nov 19 23:02 /proc/keys
crw-rw-rw-    1 root     root        1,   3 Nov 19 23:02 /proc/latency_stats
drwxrwxrwt    2 root     root            40 Nov 19 23:02 /proc/scsi
crw-rw-rw-    1 root     root        1,   3 Nov 19 23:02 /proc/timer_list
```

```bash
$ kubectl exec proc-mount-default -- ls -l /dev/null
crw-rw-rw-    1 root     root        1,   3 Nov 19 23:17 /dev/null
```

При `Default` семь имён остаются в листинге, меняется тип.

- Первая буква режима — тип файла. `c` означает символьное устройство.
- Номера `1, 3` у `interrupts`, `keys`, `kcore`, `latency_stats` и `timer_list` те же, что у `/dev/null`. 
- `acpi` и `scsi` — каталоги `drwxrwxrwt` размером 40, это не `/dev/null`. Владелец — `root`.

---

```bash
$ kubectl exec proc-mount-unmasked -- ls -ld /proc/interrupts /proc/keys /proc/kcore /proc/latency_stats /proc/timer_list /proc/acpi /proc/scsi
dr-xr-xr-x    2 nobody   nobody           0 Nov 19 23:02 /proc/acpi
-r--r--r--    1 nobody   nobody           0 Nov 19 23:02 /proc/interrupts
-r--------    1 nobody   nobody   72057594021171200 Nov 19 23:02 /proc/kcore
-r--r--r--    1 nobody   nobody           0 Nov 19 23:02 /proc/keys
-rw-r--r--    1 nobody   nobody           0 Nov 19 23:02 /proc/latency_stats
dr-xr-xr-x    3 nobody   nobody           0 Nov 19 23:02 /proc/scsi
-r--------    1 nobody   nobody           0 Nov 19 23:02 /proc/timer_list
```

При `Unmasked` первая буква `-` означает обычный файл, `d` — каталог. Размер `interrupts`, `keys`, `latency_stats` и `timer_list` равен 0. Размер `kcore` — `72057594021171200`. У `scsi` счётчик ссылок 3. Владелец — `nobody`.

Имена в обоих листингах одни и те же. При `Default` пять из них — то же устройство `1, 3`, что и `/dev/null`. `acpi` и `scsi` — каталоги `drwxrwxrwt`. При `Unmasked` это обычные файлы и каталоги. Владелец `root` или `nobody` следует из `hostUsers`.
