Записанный вывод проверки.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`. Пространство имён `default`. Оба пода из образа `archlinux`, от uid `0`. Поле `privileged` не задано. У `ape-true` задано `allowPrivilegeEscalation: true`. У `ape-false` задано `allowPrivilegeEscalation: false`.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=ape-setuid
NAME        READY   STATUS    RESTARTS   AGE
ape-false   1/1     Running   0          27s
ape-true    1/1     Running   0          27s
```

`NoNewPrivs` у `ape-true` равен `0`, у `ape-false` равен `1`. В параметрах корня нет `nosuid`:

```bash
$ grep NoNewPrivs /proc/1/status
NoNewPrivs:	0
```

```bash
$ grep NoNewPrivs /proc/1/status
NoNewPrivs:	1
```

```bash
$ findmnt -no OPTIONS /
rw,relatime,lowerdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/539/fs:/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/535/fs,upperdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/1474/fs,workdir=/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/1474/work,nouserxattr
```

У `ape-false` та же строка, номер снимка `1475`.

У обоих подов копия `/usr/bin/cat` получает бит setuid:

```bash
$ ls -l /root/token /tmp/cat-setuid
-rw------- 1 root root    15 Nov 22 06:49 /root/token
-rwsr-xr-x 1 root root 51576 Nov 22 06:49 /tmp/cat-setuid
```

Под `ape-true`. Процесс от uid `1000` читает файл. В `/proc/self/status` этой команды `Uid` — `1000 0 0 0`, `CapEff` равен `00000000a80425fb`:

```bash
$ setpriv --reuid=1000 --regid=1000 --clear-groups /tmp/cat-setuid /root/token
ape-true-token
```

Под `ape-false`. Та же команда остаётся uid `1000`: в `/proc/self/status` все четыре поля `Uid` равны `1000`, `CapEff` равен `0000000000000000`. Файл не открывается:

```bash
$ setpriv --reuid=1000 --regid=1000 --clear-groups /tmp/cat-setuid /root/token
cat-setuid: /root/token: Permission denied
```

Поды удалены.
