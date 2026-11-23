Записанный вывод проверки. Показывать, если стенд не отвечает.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. Секрет `different-uid-privileged` создан этим каталогом.
У `secret-privileged-uid` заданы `runAsNonRoot: true` и `runAsUser: 1000`.
У `hostpid-privileged` заданы `hostPID: true`, `privileged: true`, `runAsNonRoot: true` и `runAsUser: 2000`.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=hostpid-different-uid-privileged
NAME                    READY   STATUS    RESTARTS   AGE
hostpid-privileged      1/1     Running   0          4s
secret-privileged-uid   1/1     Running   0          4s
```

Переменные окружения пода `secret-privileged-uid` и идентификаторы процессов:

```bash
$ env | grep password
password=privileged_reader_password
```

```bash
$ id
uid=1000 gid=1000 groups=1000
```

Та же команда `id` в `hostpid-privileged`:

```bash
$ id
uid=2000 gid=2000 groups=2000
```

```bash
$ grep -E "^(Uid|CapEff|CapPrm)" /proc/self/status
Uid:	2000	2000	2000	2000
CapPrm:	0000000000000000
CapEff:	0000000000000000
```

Поиск процесса, который читает `/tmp/different-uid-privileged`, вернул идентификатор `428062`.

Процесс принадлежит uid `1000`. Командная строка читается:

```bash
$ grep -E "^(Name|Uid)" /proc/428062/status
Name:	tail
Uid:	1000	1000	1000	1000
```

```bash
$ tr "\0" " " < /proc/428062/cmdline; echo
tail -f /tmp/different-uid-privileged
```

Файл окружения ядро не открывает:

```bash
$ cat /proc/428062/environ | tr "\0" "\n"
cat: can't open '/proc/428062/environ': Permission denied
```
