Записанный вывод кейса файловых capabilities. Кейс для справки,
в показ не входит.

Три пода в Running после применения манифеста:

```bash
$ kubectl get pods -l case=file-capabilities
NAME         READY   STATUS    RESTARTS   AGE
add-pod      1/1     Running   0          5s
drop-pod     1/1     Running   0          5s
no-drop-pod  1/1     Running   0          5s
```

На поде `no-drop-pod` шлюз — цель для arping:

```bash
$ ip -4 route show default | awk '{print $3}'
10.96.0.42
```

На поде `drop-pod` набор снят, атрибута у файла нет:

```bash
$ arping -c1 -w2 -I eth0 10.96.0.42
arping: socket: Operation not permitted
```

На поде `no-drop-pod` атрибут на файле:

```bash
$ setcap cap_net_raw=ep /usr/sbin/arping

$ getcap /usr/sbin/arping
/usr/sbin/arping cap_net_raw=ep
```

От uid 1000 право даёт только атрибут файла:

```bash
$ setpriv --reuid=1000 --regid=1000 --clear-groups arping -c1 -w2 -I eth0 10.96.0.42
ARPING 10.96.0.42 from 10.96.0.119 eth0
Unicast reply from 10.96.0.42 [6A:22:28:70:79:D0]  0.518ms
Sent 1 probes (1 broadcast(s))
Received 1 response(s)
```

Контроль в том же поде: копия файла без атрибута от того же uid 1000
не работает:

```bash
$ cp /usr/sbin/arping /tmp/arping-copy

$ getcap /tmp/arping-copy

$ setpriv --reuid=1000 --regid=1000 --clear-groups /tmp/arping-copy -c1 -w2 -I eth0 10.96.0.42
/tmp/arping-copy: socket: Operation not permitted
```

Атрибут против пустого ограничивающего набора: файл не запускается,
execve возвращает EPERM:

```bash
$ setpriv --bounding-set=-all --inh-caps=-all --ambient-caps=-all arping -c1 -w2 -I eth0 10.96.0.42
setpriv: failed to execute arping: Operation not permitted
```

На поде `add-pod` право возвращено в под, arping работает:

```bash
$ arping -c1 -w2 -I eth0 10.96.0.42
ARPING 10.96.0.42 from 10.96.0.124 eth0
Unicast reply from 10.96.0.42 [7E:F4:07:3D:EE:70]  0.524ms
Sent 1 probes (1 broadcast(s))
Received 1 response(s)
```
