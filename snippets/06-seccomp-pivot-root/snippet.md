Команды кейса seccomp. Пути в командах указаны относительно каталога сниппета.
В манифест подов эту команду не записывать: показ идёт через kubectl exec, контейнер до показа спит.

На каждом поде один exec. Внутри него цепочка, шаги соединены `&&`:

1. `unshare -Urm` — новое пространство пользователей (`-U`), root пода становится root внутри него (`-r`), новое пространство монтирования (`-m`). Дальше работает `sh -c`.
2. `mkdir -p /tmp/newroot` — точка монтирования, до `mount`.
3. `mount -t tmpfs tmpfs /tmp/newroot` — отдельная точка, её примет `pivot_root`.
4. `mkdir -p /tmp/newroot/old` — каталог `put_old`, уже на tmpfs.
5. `pivot_root /tmp/newroot /tmp/newroot/old` — новый корень и место для прежнего.

На `RuntimeDefault` отказ приходит на шаге 1, оболочка не стартует. На `Unconfined` цепочка доходит до шага 5 и завершается вместе с `unshare`: корень пода не меняется.

Применить манифест подов `pods.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=seccomp-pivot-root
```

На поде `seccomp-runtime-default` задан профиль seccomp `RuntimeDefault`. Поле `capabilities` не задано. Вызов `unshare` завершается отказом, до `mount` и `pivot_root` выполнение не доходит
```bash
kubectl exec seccomp-runtime-default -- unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
```

На поде `seccomp-unconfined` задан профиль seccomp `Unconfined`. Та же команда завершается с кодом 0. `pivot_root` выполняется во вложенном пространстве монтирования, корень пода не меняется
```bash
kubectl exec seccomp-unconfined -- unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
```

На поде `seccomp-unset` поле `seccompProfile` не задано. AppArmor `Unconfined`, поле `capabilities` не задано. Строка `Seccomp` в `/proc/1/status` показывает, установлен ли фильтр. Затем та же команда
```bash
kubectl exec seccomp-unset -- grep ^Seccomp /proc/1/status
kubectl exec seccomp-unset -- unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
```

Удалить поды по манифесту `pods.yaml`
```bash
kubectl delete -f pods.yaml
```
