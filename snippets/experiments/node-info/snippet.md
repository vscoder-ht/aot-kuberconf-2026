Команды просмотра. Пути указаны относительно этого каталога. Кластер — управляемый: оба пода без `hostUsers` там запускаются. У пода `node-info` содержимое пяти файлов выводится. У пода `node-info-1000` те же файлы закрыты.

Применить манифест `pods.yaml`

```bash
export KUBECONFIG=../../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl delete -f pods.yaml --ignore-not-found
kubectl apply -f pods.yaml
```

Дождаться, пока оба пода перейдут в состояние Running

```bash
kubectl get pods -l case=node-info
```

Режим и содержимое от uid `0`. Четыре файла DMI — целиком. У `/proc/slabinfo` — первые строки.

```bash
kubectl exec node-info -- ls -l \
  /sys/class/dmi/id/product_uuid \
  /sys/class/dmi/id/product_serial \
  /sys/class/dmi/id/board_serial \
  /sys/class/dmi/id/chassis_serial \
  /proc/slabinfo
kubectl exec node-info -- sh -c '
  for f in \
    /sys/class/dmi/id/product_uuid \
    /sys/class/dmi/id/product_serial \
    /sys/class/dmi/id/board_serial \
    /sys/class/dmi/id/chassis_serial
  do
    echo "== $f"
    cat "$f"
  done
  echo "== /proc/slabinfo"
  sed -n "1,15p" /proc/slabinfo
'
```

Те же файлы от uid `1000`.

```bash
kubectl exec node-info-1000 -- ls -l \
  /sys/class/dmi/id/product_uuid \
  /sys/class/dmi/id/product_serial \
  /sys/class/dmi/id/board_serial \
  /sys/class/dmi/id/chassis_serial \
  /proc/slabinfo
kubectl exec node-info-1000 -- sh -c '
  for f in \
    /sys/class/dmi/id/product_uuid \
    /sys/class/dmi/id/product_serial \
    /sys/class/dmi/id/board_serial \
    /sys/class/dmi/id/chassis_serial \
    /proc/slabinfo
  do
    echo "== $f"
    cat "$f" || true
  done
'
```

Удалить поды

```bash
kubectl delete -f pods.yaml
```
