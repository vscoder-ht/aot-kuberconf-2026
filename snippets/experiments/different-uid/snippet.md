Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=hostpid-different-uid
```

Переменные окружения пода `secret-different-uid` и идентификаторы обоих процессов
```bash
kubectl exec secret-different-uid -- env | grep password
kubectl exec secret-different-uid -- id
kubectl exec hostpid-uid2000 -- id
```

Идентификатор процесса, который читает `/tmp/different-uid`. Подставить его вместо `PID`
```bash
kubectl exec hostpid-uid2000 -- sh -c 'mark="different-""uid"; for d in /proc/[0-9]*; do cmd=$(tr "\0" " " < "$d/cmdline" 2>/dev/null) || continue; printf "%s" "$cmd" | grep -q "$mark" && echo "${d#/proc/}"; done; true'
```

Uid процесса, его командная строка и окружение
```bash
kubectl exec hostpid-uid2000 -- sh -c 'grep -E "^(Name|Uid)" /proc/PID/status'
kubectl exec hostpid-uid2000 -- sh -c 'tr "\0" " " < /proc/PID/cmdline; echo'
kubectl exec hostpid-uid2000 -- sh -c 'cat /proc/PID/environ | tr "\0" "\n"'
```

Удалить ресурсы проверки
```bash
kubectl delete -f pods.yaml
```
