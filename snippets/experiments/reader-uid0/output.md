Записанный вывод проверки. Показывать, если стенд не отвечает.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. Секрет `reader-uid0` создан этим каталогом.
У `secret-reader-uid0` заданы `runAsNonRoot: true` и `runAsUser: 1000`.
У `hostpid-uid0` заданы `hostPID: true`, `privileged: false` и `runAsUser: 0`.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=hostpid-reader-uid0
NAME                 READY   STATUS    RESTARTS   AGE
hostpid-uid0         1/1     Running   0          4s
secret-reader-uid0   1/1     Running   0          4s
```

Переменные окружения пода `secret-reader-uid0` и идентификаторы процессов:

```bash
$ env | grep password
password=reader_uid0_password
```

```bash
$ id
uid=1000 gid=1000 groups=1000
```

Та же команда `id` в `hostpid-uid0`:

```bash
$ id
uid=0(root) gid=0(root) groups=0(root),10(wheel)
```

```bash
$ grep -E "^(Uid|CapEff|CapPrm)" /proc/self/status
Uid:	0	0	0	0
CapPrm:	00000000a80425fb
CapEff:	00000000a80425fb
```

Поиск процесса, который читает `/tmp/reader-uid0`, вернул идентификатор `430667`.

Процесс принадлежит uid `1000`. Командная строка читается:

```bash
$ grep -E "^(Name|Uid)" /proc/430667/status
Name:	tail
Uid:	1000	1000	1000	1000
```

```bash
$ tr "\0" " " < /proc/430667/cmdline; echo
tail -f /tmp/reader-uid0
```

Файл окружения ядро не открывает:

```bash
$ cat /proc/430667/environ | tr "\0" "\n"
cat: can't open '/proc/430667/environ': Permission denied
```
