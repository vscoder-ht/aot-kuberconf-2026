Команды проверки. Пути указаны относительно этого каталога. Кластер — k3s: на управляемом кластере под с `hostUsers: false` до `Running` не доходит. Содержимое файлов не выводится.

Применить манифест `pods.yaml`
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/k3s.kubeconfig
kubectl delete -f pods.yaml --ignore-not-found
kubectl apply -f pods.yaml
```

Дождаться, пока оба пода перейдут в состояние Running
```bash
kubectl get pods -l case=dmi-userns
```

Открытие файлов. Сначала под `info-host`, затем `info-userns`
```bash
probe='
for f in \
  /proc/version \
  /proc/cmdline \
  /proc/cpuinfo \
  /proc/slabinfo \
  /sys/class/dmi/id/sys_vendor \
  /sys/class/dmi/id/product_name \
  /sys/class/dmi/id/product_uuid \
  /sys/class/dmi/id/product_serial \
  /sys/class/dmi/id/board_serial \
  /sys/class/dmi/id/chassis_serial
 do
  if [ ! -e "$f" ]; then echo "ABSENT $f"; continue; fi
  mode=$(ls -l "$f" | awk "{print \$1, \$3}")
  if dd if="$f" of=/dev/null bs=1 count=1 >/dev/null 2>/tmp/e; then
    echo "READ $mode $f"
  else
    err=$(tr "\n" " " < /tmp/e)
    echo "DENY $mode $f $err"
  fi
 done
'
kubectl exec info-host -- sh -c "$probe"
kubectl exec info-userns -- sh -c "$probe"
```

Удалить поды
```bash
kubectl delete -f pods.yaml
```

Под `info-host` на управляемом кластере. Второй документ манифеста не применяется: под с `hostUsers: false` там до `Running` не доходит.
```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
# переменная probe задана в блоке открытия файлов выше
kubectl delete pod info-host --ignore-not-found
sed '/^---$/,$d' pods.yaml | kubectl apply -f -
kubectl get pod info-host
kubectl exec info-host -- sh -c "$probe"
kubectl delete pod info-host
```
