Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=hostpid-different-uid-privileged
```

Переменные окружения пода `secret-privileged-uid` и идентификаторы обоих процессов
```bash
kubectl exec secret-privileged-uid -- env | grep password
kubectl exec secret-privileged-uid -- id
kubectl exec hostpid-privileged -- id
kubectl exec hostpid-privileged -- sh -c 'grep -E "^(Uid|CapEff|CapPrm)" /proc/self/status'
```

Идентификатор процесса, который читает `/tmp/different-uid-privileged`. Подставить его вместо `PID`
```bash
kubectl exec hostpid-privileged -- sh -c 'mark="different-uid-""privileged"; for d in /proc/[0-9]*; do cmd=$(tr "\0" " " < "$d/cmdline" 2>/dev/null) || continue; printf "%s" "$cmd" | grep -q "$mark" && echo "${d#/proc/}"; done; true'
```

Uid процесса, его командная строка и окружение
```bash
kubectl exec hostpid-privileged -- sh -c 'grep -E "^(Name|Uid)" /proc/PID/status'
kubectl exec hostpid-privileged -- sh -c 'tr "\0" " " < /proc/PID/cmdline; echo'
kubectl exec hostpid-privileged -- sh -c 'cat /proc/PID/environ | tr "\0" "\n"'
```

Удалить ресурсы проверки
```bash
kubectl delete -f pods.yaml
```
