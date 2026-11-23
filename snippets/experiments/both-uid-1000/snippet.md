Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=hostpid-both-uid-1000
```

Переменные окружения пода `secret-uid1000` и идентификаторы обоих процессов
```bash
kubectl exec secret-uid1000 -- env | grep password
kubectl exec secret-uid1000 -- id
kubectl exec hostpid-uid1000 -- id
```

Идентификатор процесса, который читает `/tmp/both-uid-1000`. Подставить его вместо `PID`
```bash
kubectl exec hostpid-uid1000 -- sh -c 'mark="both-uid-""1000"; for d in /proc/[0-9]*; do cmd=$(tr "\0" " " < "$d/cmdline" 2>/dev/null) || continue; printf "%s" "$cmd" | grep -q "$mark" && echo "${d#/proc/}"; done; true'
```

Uid процесса и его окружение
```bash
kubectl exec hostpid-uid1000 -- sh -c 'grep -E "^(Name|Uid)" /proc/PID/status'
kubectl exec hostpid-uid1000 -- sh -c 'cat /proc/PID/environ | tr "\0" "\n"'
```

Удалить ресурсы проверки
```bash
kubectl delete -f pods.yaml
```
