Команды доставки профилей Localhost. Пути в командах указаны относительно каталога сниппета.

Применить манифест доставки `daemonsets.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl apply -f daemonsets.yaml
```

Дождаться, пока оба DaemonSet станут Ready. К этому моменту файл seccomp лежит в каталоге kubelet, профиль AppArmor загружен в ядро
```bash
kubectl rollout status daemonset/seccomp-profile-installer
kubectl rollout status daemonset/apparmor-profile-installer
```

Применить манифест подов `pods.yaml`
```bash
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=localhost-profiles
```

На поде `seccomp-localhost` задан профиль seccomp `Localhost`. В `/proc/1/status` поле `Seccomp` показывает, что фильтр установлен
```bash
kubectl exec seccomp-localhost -- grep ^Seccomp /proc/1/status
```

На поде `apparmor-localhost` задан профиль AppArmor `Localhost`. В `/proc/1/attr/current` записано имя профиля
```bash
kubectl exec apparmor-localhost -- cat /proc/1/attr/current
```

Удалить поды и DaemonSet. Файл в `/var/lib/kubelet/seccomp` и профиль AppArmor в ядре узла остаются
```bash
kubectl delete -f pods.yaml
kubectl delete -f daemonsets.yaml
```
