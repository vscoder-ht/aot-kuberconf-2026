Записанный вывод проверки.

Прогон 22 ноября 2026 на k3s стенда, Kubernetes `v1.34.12+k3s1`. Пространство имён `default`. Секрета нет. Оба пода от uid `0`, поле `privileged` не задано. У `info-host` поле `hostUsers` не задано. У `info-userns` задано `hostUsers: false`. Содержимое файлов не снималось: в файл писался один байт через `dd` в `/dev/null`.

Оба пода дошли до `Running`.

Под `info-host`:

```text
READ -r--r--r-- root /proc/version
READ -r--r--r-- root /proc/cmdline
READ -r--r--r-- root /proc/cpuinfo
READ -r-------- root /proc/slabinfo
READ -r--r--r-- root /sys/class/dmi/id/sys_vendor
READ -r--r--r-- root /sys/class/dmi/id/product_name
READ -r-------- root /sys/class/dmi/id/product_uuid
READ -r-------- root /sys/class/dmi/id/product_serial
READ -r-------- root /sys/class/dmi/id/board_serial
READ -r-------- root /sys/class/dmi/id/chassis_serial
```

Под `info-userns`:

```text
READ -r--r--r-- nobody /proc/version
READ -r--r--r-- nobody /proc/cmdline
READ -r--r--r-- nobody /proc/cpuinfo
DENY -r-------- nobody /proc/slabinfo dd: can't open '/proc/slabinfo': Permission denied
READ -r--r--r-- nobody /sys/class/dmi/id/sys_vendor
READ -r--r--r-- nobody /sys/class/dmi/id/product_name
DENY -r-------- nobody /sys/class/dmi/id/product_uuid dd: can't open '/sys/class/dmi/id/product_uuid': Permission denied
DENY -r-------- nobody /sys/class/dmi/id/product_serial dd: can't open '/sys/class/dmi/id/product_serial': Permission denied
DENY -r-------- nobody /sys/class/dmi/id/board_serial dd: can't open '/sys/class/dmi/id/board_serial': Permission denied
DENY -r-------- nobody /sys/class/dmi/id/chassis_serial dd: can't open '/sys/class/dmi/id/chassis_serial': Permission denied
```

Поды удалены.

Прогон того же дня на управляемом кластере, Kubernetes `v1.35.1`. Создан только под `info-host`. Поле `hostUsers` не задано, `privileged` не задано, uid `0`. Содержимое файлов не снималось.

Под дошёл до `Running`.

```text
READ -r--r--r-- root /proc/version
READ -r--r--r-- root /proc/cmdline
READ -r--r--r-- root /proc/cpuinfo
READ -r-------- root /proc/slabinfo
READ -r--r--r-- root /sys/class/dmi/id/sys_vendor
READ -r--r--r-- root /sys/class/dmi/id/product_name
READ -r-------- root /sys/class/dmi/id/product_uuid
READ -r-------- root /sys/class/dmi/id/product_serial
READ -r-------- root /sys/class/dmi/id/board_serial
READ -r-------- root /sys/class/dmi/id/chassis_serial
```

Под удалён.
