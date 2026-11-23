Записанный вывод проверки. Показывать, если стенд не отвечает.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. Секрет `reader-uid-1000` создан этим каталогом.
У `secret-uid0` поле `privileged` выключено, процесс идёт от uid `0`.
У `hostpid-noroot` заданы `hostPID: true`, `runAsNonRoot: true`, `runAsUser: 1000`.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=hostpid-reader-uid-1000
NAME             READY   STATUS    RESTARTS   AGE
hostpid-noroot   1/1     Running   0          7s
secret-uid0      1/1     Running   0          7s
```

На поде `secret-uid0` переменные окружения:

```bash
$ env | grep password
password=reader_uid_1000_password
```

Идентификатор и capabilities читающего процесса:

```bash
$ id
uid=1000 gid=1000 groups=1000
```

```bash
$ grep -E "^(Uid|CapEff|CapPrm)" /proc/self/status
Uid:	1000	1000	1000	1000
CapPrm:	0000000000000000
CapEff:	0000000000000000
```

Поиск процесса, который читает `/tmp/reader-uid-1000`, вернул идентификатор `421075`.

Процесс принадлежит uid `0`. Командная строка читается:

```bash
$ grep -E "^(Name|Uid)" /proc/421075/status
Name:	tail
Uid:	0	0	0	0
```

```bash
$ tr "\0" " " < /proc/421075/cmdline; echo
tail -f /tmp/reader-uid-1000
```

Файл окружения ядро не открывает:

```bash
$ cat /proc/421075/environ | tr "\0" "\n"
cat: can't open '/proc/421075/environ': Permission denied
```
