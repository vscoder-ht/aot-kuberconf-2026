Команды кейса procMount. Пути в командах указаны относительно каталога сниппета.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/k3s.kubeconfig
kubectl apply -f pods.yaml
```

Дождаться, пока оба пода перейдут в состояние Running
```bash
kubectl get pods -l case=proc-mount
```

На поде `proc-mount-default` задано `procMount: Default`. Поле `hostUsers` не задано. В кадре семь имён, затем `/dev/null`: номера `1, 3` у него те же
```bash
kubectl exec proc-mount-default -- ls -ld /proc/interrupts /proc/keys /proc/kcore /proc/latency_stats /proc/timer_list /proc/acpi /proc/scsi
kubectl exec proc-mount-default -- ls -l /dev/null
```

На поде `proc-mount-unmasked` заданы `hostUsers: false` и `procMount: Unmasked`. Те же семь имён
```bash
kubectl exec proc-mount-unmasked -- ls -ld /proc/interrupts /proc/keys /proc/kcore /proc/latency_stats /proc/timer_list /proc/acpi /proc/scsi
```

Удалить поды по манифесту `pods.yaml`
```bash
kubectl delete -f pods.yaml
```
