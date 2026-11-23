Команды кейса AppArmor. Пути в командах указаны относительно каталога сниппета.

Применить манифест подов `pods.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=apparmor-mount
```

На поде `apparmor-runtime-default` задан профиль AppArmor `RuntimeDefault`. Вызов mount с типом tmpfs завершается отказом. В файле `/proc/1/attr/current` записано имя профиля
```bash
kubectl exec apparmor-runtime-default -- mkdir /tmp/newroot
kubectl exec apparmor-runtime-default -- mount -t tmpfs tmpfs /tmp/newroot
kubectl exec apparmor-runtime-default -- cat /proc/1/attr/current
```

На поде `apparmor-unconfined` задан профиль AppArmor `Unconfined`. Тот же вызов mount проходит. В файле `/proc/1/attr/current` записано имя профиля
```bash
kubectl exec apparmor-unconfined -- mkdir /tmp/newroot
kubectl exec apparmor-unconfined -- mount -t tmpfs tmpfs /tmp/newroot
kubectl exec apparmor-unconfined -- cat /proc/1/attr/current
```

На поде `apparmor-unset` поле `appArmorProfile` не задано. Те же `SYS_ADMIN` и seccomp `Unconfined`. Тот же вызов mount и то же чтение профиля
```bash
kubectl exec apparmor-unset -- mkdir /tmp/newroot
kubectl exec apparmor-unset -- mount -t tmpfs tmpfs /tmp/newroot
kubectl exec apparmor-unset -- cat /proc/1/attr/current
```

Удалить поды по манифесту `pods.yaml`
```bash
kubectl delete -f pods.yaml
```
