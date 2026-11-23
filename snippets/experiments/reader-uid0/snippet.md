Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=hostpid-reader-uid0
```

Переменные окружения пода `secret-reader-uid0` и идентификаторы обоих процессов
```bash
kubectl exec secret-reader-uid0 -- env | grep password
kubectl exec secret-reader-uid0 -- id
kubectl exec hostpid-uid0 -- id
kubectl exec hostpid-uid0 -- sh -c 'grep -E "^(Uid|CapEff|CapPrm)" /proc/self/status'
```

Идентификатор процесса, который читает `/tmp/reader-uid0`. Подставить его вместо `PID`
```bash
kubectl exec hostpid-uid0 -- sh -c 'mark="reader-""uid0"; for d in /proc/[0-9]*; do cmd=$(tr "\0" " " < "$d/cmdline" 2>/dev/null) || continue; printf "%s" "$cmd" | grep -q "$mark" && echo "${d#/proc/}"; done; true'
```

Uid процесса, его командная строка и окружение
```bash
kubectl exec hostpid-uid0 -- sh -c 'grep -E "^(Name|Uid)" /proc/PID/status'
kubectl exec hostpid-uid0 -- sh -c 'tr "\0" " " < /proc/PID/cmdline; echo'
kubectl exec hostpid-uid0 -- sh -c 'cat /proc/PID/environ | tr "\0" "\n"'
```

Удалить ресурсы проверки
```bash
kubectl delete -f pods.yaml
```
