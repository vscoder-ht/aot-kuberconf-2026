Записанный вывод проверки. Показывать, если стенд не отвечает.

Прогон 22 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. Секрет `both-uid-1000` создан этим каталогом.
У обоих подов заданы `runAsNonRoot: true` и `runAsUser: 1000`.
У `hostpid-uid1000` задан `hostPID: true`, поле `privileged` отсутствует.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=hostpid-both-uid-1000
NAME              READY   STATUS    RESTARTS   AGE
hostpid-uid1000   1/1     Running   0          4s
secret-uid1000    1/1     Running   0          4s
```

Переменные окружения пода `secret-uid1000` и идентификаторы процессов:

```bash
$ env | grep password
password=both_uid_1000_password
```

```bash
$ id
uid=1000 gid=1000 groups=1000
```

Та же команда `id` в `hostpid-uid1000` дала тот же вывод.

Поиск процесса, который читает `/tmp/both-uid-1000`, вернул идентификатор `421424`.

Процесс принадлежит uid `1000`. Это `tail` пода `secret-uid1000`. Окружение читается:

```bash
$ grep -E "^(Name|Uid)" /proc/421424/status
Name:	tail
Uid:	1000	1000	1000	1000
```

```bash
$ cat /proc/421424/environ | tr "\0" "\n"
KUBERNETES_PORT=tcp://10.112.0.1:443
KUBERNETES_SERVICE_PORT=443
HOSTNAME=secret-uid1000
SHLVL=1
HOME=/
KUBERNETES_PORT_443_TCP_ADDR=10.112.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
password=both_uid_1000_password
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.112.0.1:443
KUBERNETES_SERVICE_HOST=10.112.0.1
PWD=/
```
