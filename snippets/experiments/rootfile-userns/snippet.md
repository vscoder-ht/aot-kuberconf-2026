Команды проверки. Пути указаны относительно этого каталога. Кластер — k3s: на управляемом кластере под с `hostUsers: false` до `Running` не доходит.

Подготовить файл root на узле
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/k3s.kubeconfig
kubectl delete -f prep.yaml --ignore-not-found
kubectl apply -f prep.yaml
```

Дождаться завершения пода `rootfile-prep` и посмотреть владельца файла
```bash
kubectl get pod rootfile-prep
kubectl logs rootfile-prep
```

Применить поды проверки
```bash
kubectl delete -f pods.yaml --ignore-not-found
kubectl apply -f pods.yaml
```

Дождаться, пока оба пода перейдут в состояние Running
```bash
kubectl get pods -l case=rootfile-userns
```

Под `rootfile-userns0`. Идентификатор, содержимое `/proc/self/uid_map`, монтирование `/data`, владелец файла, чтение
```bash
kubectl exec rootfile-userns0 -- id
kubectl exec rootfile-userns0 -- cat /proc/self/uid_map
kubectl exec rootfile-userns0 -- sh -c 'grep " /data " /proc/self/mountinfo'
kubectl exec rootfile-userns0 -- ls -ln /data/token
kubectl exec rootfile-userns0 -- cat /data/token
```

Под `rootfile-userns1000`. Идентификатор, владелец файла, чтение
```bash
kubectl exec rootfile-userns1000 -- id
kubectl exec rootfile-userns1000 -- ls -ln /data/token
kubectl exec rootfile-userns1000 -- cat /data/token
```

Удалить поды. Каталог `/var/tmp/rootread` на узле остаётся
```bash
kubectl delete -f pods.yaml
kubectl delete -f prep.yaml --ignore-not-found
```
