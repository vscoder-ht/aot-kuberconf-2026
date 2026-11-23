Записанный вывод кейса seccomp. Показывать, если стенд не отвечает.

Прогон сниппета на управляемом кластере стенда, Kubernetes `v1.35.1`, containerd `2.2.1`.
Контекст `yc-stand-mk8s`, пространство имён `default`. 23 ноября 2026.

Три пода в Running после применения манифеста:

```bash
$ kubectl get pods -l case=seccomp-pivot-root
NAME                      READY   STATUS    RESTARTS   AGE
seccomp-runtime-default   1/1     Running   0          3s
seccomp-unconfined        1/1     Running   0          3s
seccomp-unset             1/1     Running   0          3s
```

На поде `seccomp-runtime-default` поле `Seccomp` равно `2`, `CapEff` равен `00000000a80425fb`.
`unshare` отказывает, до `mount` и `pivot_root` выполнение не доходит:

```bash
$ unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
unshare: unshare(0x10020000): Operation not permitted
```

На поде `seccomp-unconfined` поле `Seccomp` равно `0`, `CapEff` тот же.
Команда завершается с кодом 0. Корень пода остаётся `/`:

```bash
$ unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
```

Под `seccomp-unset` без поля `seccompProfile`. В объекте пода поля нет, аннотации seccomp нет.
Фильтр не установлен, как у `Unconfined`. Та же команда завершается с кодом 0:

```bash
$ grep ^Seccomp /proc/1/status
Seccomp:	0
Seccomp_filters:	0

$ unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
```

У `seccomp-runtime-default` в той же строке `Seccomp` равно `2`, `Seccomp_filters` равно `1`.
