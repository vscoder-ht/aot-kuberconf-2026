Записанный вывод кейса AppArmor. Показывать, если стенд не отвечает.

Прогон сниппета на управляемом кластере стенда, Kubernetes `v1.35.1`.
Контекст `yc-stand-mk8s`, пространство имён `default`.

Оба пода в Running после применения манифеста:

```bash
$ kubectl get pods -l case=apparmor-mount
NAME                       READY   STATUS    RESTARTS   AGE
apparmor-runtime-default   1/1     Running   0          5s
apparmor-unconfined        1/1     Running   0          5s
```

На поде `apparmor-runtime-default` `mount` типа tmpfs отказывает:

```bash
$ mkdir /tmp/newroot

$ mount -t tmpfs tmpfs /tmp/newroot
mount: mounting tmpfs on /tmp/newroot failed: Permission denied

$ cat /proc/1/attr/current
cri-containerd.apparmor.d (enforce)
```

На поде `apparmor-unconfined` та же команда завершается с кодом 0:

```bash
$ mkdir /tmp/newroot

$ mount -t tmpfs tmpfs /tmp/newroot

$ cat /proc/1/attr/current
unconfined

$ grep newroot /proc/mounts
tmpfs /tmp/newroot tmpfs rw,relatime,inode64 0 0
```

Профили различает `mount`. Прохождение на `Unconfined` — снятие профиля.

Под `apparmor-unset` без поля `appArmorProfile`, 18 ноября 2026, тот же кластер.
В объекте пода поля нет, аннотации AppArmor нет. Профиль тот же, что у `RuntimeDefault`:

```bash
$ mkdir /tmp/newroot

$ mount -t tmpfs tmpfs /tmp/newroot
mount: mounting tmpfs on /tmp/newroot failed: Permission denied

$ cat /proc/1/attr/current
cri-containerd.apparmor.d (enforce)
```
