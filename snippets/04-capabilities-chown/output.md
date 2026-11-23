Записанный вывод кейса capabilities. Показывать, если стенд не отвечает.
Прогон 22 ноября 2026 на управляемом кластере, Kubernetes `v1.35.1`. Образ — `alpine:3.20`.

Оба пода в Running после применения манифеста:

```bash
$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
cap-add-pod    1/1     Running   0          49s
cap-drop-pod   1/1     Running   0          49s
```

Наборы capabilities. У `cap-drop-pod` после `drop: [ALL]` все маски нулевые.
У `cap-add-pod` в `CapPrm`, `CapEff` и `CapBnd` значение `0000000000000001`.

На поде `cap-drop-pod`:

```bash
$ grep Cap /proc/1/status
CapInh:	0000000000000000
CapPrm:	0000000000000000
CapEff:	0000000000000000
CapBnd:	0000000000000000
CapAmb:	0000000000000000
```

На поде `cap-add-pod`:

```bash
$ grep Cap /proc/1/status
CapInh:	0000000000000000
CapPrm:	0000000000000001
CapEff:	0000000000000001
CapBnd:	0000000000000001
CapAmb:	0000000000000000
```

Пакет `libcap` в образ не входит. Его ставят в уже запущенный контейнер. На обоих подах вывод установки одинаковый:

```bash
$ apk add --no-cache libcap
fetch https://dl-cdn.alpinelinux.org/alpine/v3.20/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.20/community/x86_64/APKINDEX.tar.gz
(1/5) Installing libcap2 (2.78-r0)
(2/5) Installing libcap-getcap (2.78-r0)
(3/5) Installing libcap-setcap (2.78-r0)
(4/5) Installing libcap-utils (2.78-r0)
(5/5) Installing libcap (2.78-r0)
Executing busybox-1.36.1-r31.trigger
OK: 8 MiB in 19 packages
```

`capsh --decode` читает маску из `/proc/1/status`. Пустая маска — пустой набор. `0000000000000001` — `cap_chown`.

На поде `cap-drop-pod`:

```bash
$ grep ^Cap /proc/1/status | while read -r name mask; do printf '%s\t%s\n' "$name" "$(capsh --decode=$mask)"; done
CapInh:	0x0000000000000000=
CapPrm:	0x0000000000000000=
CapEff:	0x0000000000000000=
CapBnd:	0x0000000000000000=
CapAmb:	0x0000000000000000=
```

На поде `cap-add-pod`:

```bash
$ grep ^Cap /proc/1/status | while read -r name mask; do printf '%s\t%s\n' "$name" "$(capsh --decode=$mask)"; done
CapInh:	0x0000000000000000=
CapPrm:	0x0000000000000001=cap_chown
CapEff:	0x0000000000000001=cap_chown
CapBnd:	0x0000000000000001=cap_chown
CapAmb:	0x0000000000000000=
```

На поде `cap-drop-pod` смена владельца без CHOWN не проходит, хотя процесс — root:

```bash
$ chown 1000 /root/artifact
chown: /root/artifact: Operation not permitted
```

На поде `cap-add-pod` та же команда с `add: [CHOWN]` проходит, владелец — 1000:

```bash
$ chown 1000 /root/artifact

$ ls -ln /root/artifact
-rw-r--r--    1 1000     0                0 Nov 22 08:39 /root/artifact
```
