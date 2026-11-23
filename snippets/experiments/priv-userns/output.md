Записанный вывод проверки.

Прогон 22 ноября 2026 на k3s стенда, Kubernetes `v1.34.12+k3s1`. Пространство имён `default`. Секрета нет. У пода `priv-userns` заданы `privileged: true`, `hostUsers: false` и `runAsUser: 0`. Поле `hostPID` не задано.

Состояние пода после применения манифеста:

```bash
$ kubectl get pod priv-userns
NAME          READY   STATUS    RESTARTS   AGE
priv-userns   1/1     Running   0          2s
```

Внутри uid `0`. `CapEff` и `CapBnd` равны `000001ffffffffff`. AppArmor — `unconfined`. В `/proc/self/uid_map` строка `0 4185784320 65536`:

```bash
$ id
uid=0(root) gid=0(root) groups=0(root),10(wheel)
```

```bash
$ grep -E "^(Uid|CapEff|CapBnd)" /proc/self/status; echo apparmor:$(cat /proc/self/attr/current)
Uid:	0	0	0	0
CapEff:	000001ffffffffff
CapBnd:	000001ffffffffff
apparmor:unconfined
```

```bash
$ cat /proc/self/uid_map
         0 4185784320      65536
```

Устройство `/dev/vda1` есть. Владелец — `nobody`:

```bash
$ ls -l /dev/vda1
brw-rw----    1 nobody   nobody    253,   1 Nov 12 02:50 /dev/vda1
```

`mount` завершается с кодом `1`. Точка `/tmp/hostroot` не появляется:

```bash
$ mount -t ext4 /dev/vda1 /tmp/hostroot; echo mount-exit:$?
mount: permission denied (are you root?)
mount-exit:1
```

```bash
$ grep " /tmp/hostroot " /proc/self/mountinfo || echo no-mount
no-mount
```

Под удалён.
