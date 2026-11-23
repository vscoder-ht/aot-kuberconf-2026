Команды проверки. Пути указаны относительно этого каталога. Кластер — k3s: на управляемом кластере под с `hostUsers: false` до `Running` не доходит.

Подготовить каталоги на узле
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/k3s.kubeconfig
kubectl delete -f prep.yaml --ignore-not-found
kubectl apply -f prep.yaml
```

Дождаться завершения пода `shared-uid-prep`
```bash
kubectl get pod shared-uid-prep
```

Применить поды проверки
```bash
kubectl delete -f pods.yaml --ignore-not-found
kubectl apply -f pods.yaml
```

Дождаться, пока четыре пода перейдут в состояние Running
```bash
kubectl get pods -l case=shared-uid
```

Пара без `hostUsers`. Идентификатор, содержимое `/proc/self/uid_map`, файл режима `0600`, чтение вторым подом
```bash
kubectl exec writer-host -- id
kubectl exec writer-host -- cat /proc/self/uid_map
kubectl exec writer-host -- sh -c 'echo shared-host-token > /data/token && chmod 600 /data/token && ls -ln /data/token'
kubectl exec reader-host -- id
kubectl exec reader-host -- cat /proc/self/uid_map
kubectl exec reader-host -- ls -ln /data/token
kubectl exec reader-host -- cat /data/token
```

Пара с `hostUsers: false`. Те же команды
```bash
kubectl exec writer-userns -- id
kubectl exec writer-userns -- cat /proc/self/uid_map
kubectl exec writer-userns -- sh -c 'echo shared-userns-token > /data/token && chmod 600 /data/token && ls -ln /data/token'
kubectl exec reader-userns -- id
kubectl exec reader-userns -- cat /proc/self/uid_map
kubectl exec reader-userns -- ls -ln /data/token
kubectl exec reader-userns -- cat /data/token
```

Удалить поды. Каталоги `/var/tmp/kuberconf-shared-host` и `/var/tmp/kuberconf-shared-userns` на узле остаются
```bash
kubectl delete -f pods.yaml
kubectl delete -f prep.yaml --ignore-not-found
```
