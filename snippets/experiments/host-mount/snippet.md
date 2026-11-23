Команды проверки. Пути указаны относительно этого каталога.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=host-mount
```

Под `hostpid-mount-nopriv`: идентификатор, возможности, переход к корню узла и вызов `mount`
```bash
kubectl exec hostpid-mount-nopriv -- id
kubectl exec hostpid-mount-nopriv -- sh -c 'grep -E "^(Uid|CapEff)" /proc/self/status'
kubectl exec hostpid-mount-nopriv -- sh -c 'ls -ld /proc/1/root /proc/1/root/etc'
kubectl exec hostpid-mount-nopriv -- sh -c 'mkdir -p /tmp/hostetc; mount -o bind /proc/1/root/etc /tmp/hostetc'
kubectl exec hostpid-mount-nopriv -- sh -c 'ls -l /dev/vda1'
kubectl exec hostpid-mount-nopriv -- sh -c 'mkdir -p /tmp/hostroot; mount -t ext4 /dev/vda1 /tmp/hostroot'
```

Под `hostpid-mount-priv`: тот же набор и чтение файла `root` с режимом `0600` на смонтированном диске. Содержимое файла не выводится
```bash
kubectl exec hostpid-mount-priv -- id
kubectl exec hostpid-mount-priv -- sh -c 'grep -E "^(Uid|CapEff)" /proc/self/status; echo apparmor:$(cat /proc/self/attr/current)'
kubectl exec hostpid-mount-priv -- sh -c 'ls -ld /proc/1/root/etc'
kubectl exec hostpid-mount-priv -- sh -c 'awk "\$2==\"/\" {print \$1, \$2, \$3}" /proc/1/mounts'
kubectl exec hostpid-mount-priv -- sh -c 'mkdir -p /tmp/hostetc; mount -o bind /proc/1/root/etc /tmp/hostetc'
kubectl exec hostpid-mount-priv -- sh -c 'mkdir -p /tmp/hostroot; mount -t ext4 /dev/vda1 /tmp/hostroot; echo mount-exit:$?'
kubectl exec hostpid-mount-priv -- sh -c 'f=/tmp/hostroot/etc/ssh/ssh_host_ed25519_key; ls -l "$f" | awk "{print \$1, \$3}"; if dd if="$f" of=/dev/null bs=1 count=1 >/dev/null 2>/tmp/e; then echo read-ok; else echo read-fail; fi; umount /tmp/hostroot'
```

Под `hostpath-mount`: каталог узла уже смонтирован kubelet. Читается тот же файл, содержимое не выводится
```bash
kubectl exec hostpath-mount -- id
kubectl exec hostpath-mount -- sh -c 'grep CapEff /proc/self/status'
kubectl exec hostpath-mount -- sh -c 'ls -ld /host-etc'
kubectl exec hostpath-mount -- sh -c 'f=/host-etc/ssh/ssh_host_ed25519_key; ls -l "$f" | awk "{print \$1, \$3}"; if dd if="$f" of=/dev/null bs=1 count=1 >/dev/null 2>/tmp/e; then echo read-ok; else echo read-fail; fi'
```

Удалить ресурсы проверки
```bash
kubectl delete -f pods.yaml
```
