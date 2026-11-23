Записанный вывод проверки.

Прогон 22 ноября 2026 на k3s стенда, Kubernetes `v1.34.12+k3s1`. Пространство имён `default`. Секрета нет. Оба пода пары запускаются с `runAsNonRoot: true` и `runAsUser: 1000`. У пары `writer-host` и `reader-host` поле `hostUsers` не задано. У пары `writer-userns` и `reader-userns` задано `hostUsers: false`.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=shared-uid
NAME              READY   STATUS      RESTARTS   AGE
reader-host       1/1     Running     0          26s
reader-userns     1/1     Running     0          26s
shared-uid-prep   0/1     Completed   0          27s
writer-host       1/1     Running     0          26s
writer-userns     1/1     Running     0          26s
```

Пара без `hostUsers`. Оба процесса от uid `1000`, в `/proc/self/uid_map` строка `0 0 4294967295`. Второй под читает файл:

```bash
$ id
uid=1000 gid=1000 groups=1000
```

```bash
$ cat /proc/self/uid_map
         0          0 4294967295
```

```bash
$ ls -ln /data/token
-rw-------    1 1000     1000            18 Nov 22 06:49 /data/token
```

```bash
$ cat /data/token
shared-host-token
```

Пара с `hostUsers: false`. Внутри оба процесса тоже uid `1000`. Карты разные: у `writer-userns` начало `4141088768`, у `reader-userns` начало `1987117056`, длина обеих `65536`. Второй под файл читает:

```bash
$ id
uid=1000 gid=1000 groups=1000
```

```bash
$ cat /proc/self/uid_map
         0 4141088768      65536
```

```bash
$ cat /proc/self/uid_map
         0 1987117056      65536
```

```bash
$ ls -ln /data/token
-rw-------    1 1000     1000            20 Nov 22 06:49 /data/token
```

```bash
$ cat /data/token
shared-userns-token
```

В `mountinfo` у пары без `hostUsers` точка `/data` без флага `idmapped`. У пары с `hostUsers: false` у `/data` стоит `idmapped`, файловая система — ext4 на `/dev/vda1`.

Под без `hostUsers` смонтировал оба каталога и показал владельца на узле. Оба файла принадлежат uid `1000`:

```bash
$ ls -ln /host /userns
/host:
-rw-------    1 1000     1000            18 Nov 22 06:49 token

/userns:
-rw-------    1 1000     1000            20 Nov 22 06:49 token
```

Под с `hostPID: true` прочитал `Uid` процесса `sleep` в `/proc/<pid>/status`. У `writer-userns` это `4141089768`, у `reader-userns` это `1987118056`. Эти команды в `snippet.md` не входят.

Поды проверки удалены. Каталоги `/var/tmp/kuberconf-shared-host` и `/var/tmp/kuberconf-shared-userns` на узле остались.
