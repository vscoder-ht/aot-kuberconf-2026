Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=hostpid-reader-uid-1000
```

Переменные окружения пода `secret-uid0`
```bash
kubectl exec secret-uid0 -- env | grep password
```

Идентификатор и capabilities читающего процесса
```bash
kubectl exec hostpid-noroot -- id
kubectl exec hostpid-noroot -- sh -c 'grep -E "^(Uid|CapEff|CapPrm)" /proc/self/status'
```

Идентификатор процесса, который читает `/tmp/reader-uid-1000`. Подставить его вместо `PID`
```bash
kubectl exec hostpid-noroot -- sh -c 'mark="reader-uid-""1000"; for d in /proc/[0-9]*; do cmd=$(tr "\0" " " < "$d/cmdline" 2>/dev/null) || continue; printf "%s" "$cmd" | grep -q "$mark" && echo "${d#/proc/}"; done; true'
```

Uid процесса и его командная строка
```bash
kubectl exec hostpid-noroot -- sh -c 'grep -E "^(Name|Uid)" /proc/PID/status'
kubectl exec hostpid-noroot -- sh -c 'tr "\0" " " < /proc/PID/cmdline; echo'
```

Файл окружения этого процесса
```bash
kubectl exec hostpid-noroot -- sh -c 'cat /proc/PID/environ | tr "\0" "\n"'
```

Удалить ресурсы проверки
```bash
kubectl delete -f pods.yaml
```
