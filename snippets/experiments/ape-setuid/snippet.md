Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml --ignore-not-found
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=ape-setuid
```

Флаг `NoNewPrivs` и параметры монтирования корня. У `ape-false` флаг равен `1`. Строка `nosuid` в монтировании корня делает бит setuid бесполезным в обоих подах
```bash
kubectl exec ape-true -- grep NoNewPrivs /proc/1/status
kubectl exec ape-false -- grep NoNewPrivs /proc/1/status
kubectl exec ape-true -- findmnt -no OPTIONS /
kubectl exec ape-false -- findmnt -no OPTIONS /
```

Под `ape-true`. Файл root режима `0600`, копия `cat` с битом setuid, чтение от uid `1000`
```bash
kubectl exec ape-true -- bash -c 'echo ape-true-token > /root/token && chmod 600 /root/token && cp /usr/bin/cat /tmp/cat-setuid && chown 0:0 /tmp/cat-setuid && chmod 4755 /tmp/cat-setuid && ls -l /root/token /tmp/cat-setuid'
kubectl exec ape-true -- setpriv --reuid=1000 --regid=1000 --clear-groups /tmp/cat-setuid /root/token
```

Под `ape-false`. Те же команды
```bash
kubectl exec ape-false -- bash -c 'echo ape-false-token > /root/token && chmod 600 /root/token && cp /usr/bin/cat /tmp/cat-setuid && chown 0:0 /tmp/cat-setuid && chmod 4755 /tmp/cat-setuid && ls -l /root/token /tmp/cat-setuid'
kubectl exec ape-false -- setpriv --reuid=1000 --regid=1000 --clear-groups /tmp/cat-setuid /root/token
```

Удалить поды
```bash
kubectl delete -f pods.yaml
```
