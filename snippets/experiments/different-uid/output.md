Записанный вывод проверки. Показывать, если стенд не отвечает.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. Секрет `different-uid` создан этим каталогом.
У `secret-different-uid` заданы `runAsNonRoot: true` и `runAsUser: 1000`.
У `hostpid-uid2000` заданы `hostPID: true`, `runAsNonRoot: true` и `runAsUser: 2000`. Поле `privileged` отсутствует.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=hostpid-different-uid
NAME                   READY   STATUS    RESTARTS   AGE
hostpid-uid2000        1/1     Running   0          3s
secret-different-uid   1/1     Running   0          3s
```

Переменные окружения пода `secret-different-uid` и идентификаторы процессов:

```bash
$ env | grep password
password=different_uid_password
```

```bash
$ id
uid=1000 gid=1000 groups=1000
```

Та же команда `id` в `hostpid-uid2000`:

```bash
$ id
uid=2000 gid=2000 groups=2000
```

Поиск процесса, который читает `/tmp/different-uid`, вернул идентификатор `425446`.

Процесс принадлежит uid `1000`. Командная строка читается:

```bash
$ grep -E "^(Name|Uid)" /proc/425446/status
Name:	tail
Uid:	1000	1000	1000	1000
```

```bash
$ tr "\0" " " < /proc/425446/cmdline; echo
tail -f /tmp/different-uid
```

Файл окружения ядро не открывает:

```bash
$ cat /proc/425446/environ | tr "\0" "\n"
cat: can't open '/proc/425446/environ': Permission denied
```
