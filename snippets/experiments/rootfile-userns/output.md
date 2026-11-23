Записанный вывод проверки.

Прогон 22 ноября 2026 на k3s стенда, Kubernetes `v1.34.12+k3s1`. Пространство имён `default`. Секрета нет. Под `rootfile-prep` без поля `hostUsers` создал файл от uid `0`. Поды `rootfile-userns0` и `rootfile-userns1000` задают `hostUsers: false` и монтируют тот же каталог.

Файл после подготовки:

```bash
$ ls -ln /data/token
-rw-------    1 0        0               16 Nov 22 07:06 /data/token
```

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=rootfile-userns
NAME                  READY   STATUS      RESTARTS   AGE
rootfile-prep         0/1     Completed   0          6s
rootfile-userns0      1/1     Running     0          3s
rootfile-userns1000   1/1     Running     0          3s
```

Под `rootfile-userns0`. Внутри uid `0`, в `/proc/self/uid_map` строка `0 1697579008 65536`. Точка `/data` с флагом `idmapped`. Файл читается:

```bash
$ id
uid=0(root) gid=0(root) groups=0(root),10(wheel)
```

```bash
$ cat /proc/self/uid_map
         0 1697579008      65536
```

```bash
$ grep " /data " /proc/self/mountinfo
1527 1519 253:1 /var/tmp/rootread /data rw,relatime,idmapped - ext4 /dev/vda1 rw,discard,errors=remount-ro,commit=30
```

```bash
$ ls -ln /data/token
-rw-------    1 0        0               16 Nov 22 07:06 /data/token
```

```bash
$ cat /data/token
root-only-token
```

Под `rootfile-userns1000`. Внутри uid `1000`, владелец файла `0`. Чтение не проходит:

```bash
$ id
uid=1000 gid=1000 groups=1000
```

```bash
$ ls -ln /data/token
-rw-------    1 0        0               16 Nov 22 07:06 /data/token
```

```bash
$ cat /data/token
cat: can't open '/data/token': Permission denied
```

Поды удалены. Файл `token` удалён. Каталог проверки — `/var/tmp/rootread`.
