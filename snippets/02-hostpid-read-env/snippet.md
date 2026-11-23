Команды кейса для чтения переменных окружения. Пути в командах указаны относительно каталога сниппета.

Пересоздать поды по манифесту `pods.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=privileged-read-env
```

На поде `secret-pod` прочитать переменные окружения процесса
```bash
kubectl exec secret-pod -- env | grep password
```

На поде `hostpid-pod` задан `hostPID: true`. Смотрим список процессов
```bash
kubectl exec hostpid-pod -- ps
```

Идентификатор процесса `tail` соседнего пода. Подставить его вместо `PID` в следующей команде
```bash
kubectl exec hostpid-pod -- pidof tail
```

Переменные окружения этого процесса
```bash
kubectl exec hostpid-pod -- sh -c 'cat /proc/PID/environ | tr "\0" "\n"'
```

Удалить поды и Secret по манифесту `pods.yaml`
```bash
kubectl delete -f pods.yaml
```
