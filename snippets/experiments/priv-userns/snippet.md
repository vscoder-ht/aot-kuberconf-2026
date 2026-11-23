Команды проверки. Пути указаны относительно этого каталога. Кластер — k3s: на управляемом кластере под с `hostUsers: false` до `Running` не доходит.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/k3s.kubeconfig
kubectl delete -f pods.yaml --ignore-not-found
kubectl apply -f pods.yaml
```

Дождаться, пока под перейдёт в состояние Running
```bash
kubectl get pods -l case=priv-userns
```

Идентификатор, возможности, содержимое `/proc/self/uid_map`, устройство диска и `mount`
```bash
kubectl exec priv-userns -- id
kubectl exec priv-userns -- sh -c 'grep -E "^(Uid|CapEff|CapBnd)" /proc/self/status; echo apparmor:$(cat /proc/self/attr/current)'
kubectl exec priv-userns -- cat /proc/self/uid_map
kubectl exec priv-userns -- ls -l /dev/vda1
kubectl exec priv-userns -- sh -c 'mkdir -p /tmp/hostroot; mount -t ext4 /dev/vda1 /tmp/hostroot; echo mount-exit:$?'
kubectl exec priv-userns -- sh -c 'grep " /tmp/hostroot " /proc/self/mountinfo || echo no-mount'
```

Удалить под
```bash
kubectl delete -f pods.yaml
```
