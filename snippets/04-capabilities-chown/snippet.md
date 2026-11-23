Команды кейса capabilities. Пути в командах указаны относительно каталога сниппета.

Применить манифест подов `pods.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=capabilities-chown
```

На подах `cap-drop-pod` и `cap-add-pod` прочитать наборы capabilities процесса из файла `/proc/1/status`
```bash
kubectl exec cap-drop-pod -- grep Cap /proc/1/status
kubectl exec cap-add-pod -- grep Cap /proc/1/status
```

На тех же подах доустановить пакет `libcap`. В образ он не входит. Пакет даёт команду `capsh`
```bash
kubectl exec cap-drop-pod -- apk add --no-cache libcap
kubectl exec cap-add-pod -- apk add --no-cache libcap
```

Расшифровать маски из `/proc/1/status`. Пустая маска — пустой набор. Маска `0000000000000001` — право `cap_chown`
```bash
kubectl exec cap-drop-pod -- sh -c 'grep ^Cap /proc/1/status | while read -r name mask; do printf "%s\t%s\n" "$name" "$(capsh --decode=$mask)"; done'
kubectl exec cap-add-pod -- sh -c 'grep ^Cap /proc/1/status | while read -r name mask; do printf "%s\t%s\n" "$name" "$(capsh --decode=$mask)"; done'
```

На поде `cap-drop-pod` сменить владельца файла `/root/artifact` без capability CHOWN
```bash
kubectl exec cap-drop-pod -- chown 1000 /root/artifact
```

На поде `cap-add-pod` выполнить ту же команду с capability CHOWN и проверить владельца файла
```bash
kubectl exec cap-add-pod -- chown 1000 /root/artifact
kubectl exec cap-add-pod -- ls -ln /root/artifact
```

Удалить поды по манифесту `pods.yaml`
```bash
kubectl delete -f pods.yaml
```
