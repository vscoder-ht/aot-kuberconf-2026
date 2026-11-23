Команды кейса файловых capabilities. Кейс справочный и в показ мастер-класса не входит.
Пути в командах указаны относительно каталога сниппета. Шаги выполняются сверху вниз.
Порядок шагов совпадает со строками таблицы в README.md.

## 1. Подготовка

Применить манифест подов `pods.yaml`
```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl apply -f pods.yaml
```

Дождаться, пока поды перейдут в состояние Running
```bash
kubectl get pods -l case=file-capabilities
```

На поде `no-drop-pod` запомнить адрес шлюза маршрута default. Этот адрес служит целью для команды arping во всех проверках ниже
```bash
GW=$(kubectl exec no-drop-pod -- ip -4 route show default | awk '{print $3}')
```

## 2. Негатив: нет ни capability NET_RAW, ни файлового атрибута

На поде `drop-pod` набор capabilities процесса снят через `drop: [ALL]`. У файла `/usr/sbin/arping` нет атрибута `security.capability`
```bash
kubectl exec drop-pod -- arping -c1 -w2 -I eth0 "$GW"
```

## 3. Файловый атрибут capabilities

На поде `no-drop-pod` файлу `/usr/sbin/arping` выдаётся атрибут `cap_net_raw=ep`. Команда getcap подтверждает атрибут
```bash
kubectl exec no-drop-pod -- setcap cap_net_raw=ep /usr/sbin/arping
kubectl exec no-drop-pod -- getcap /usr/sbin/arping
```

## 4. Позитив: capability даёт атрибут файла

На поде `no-drop-pod` процесс стартует от uid 1000. У процесса своих capabilities нет. Capability NET_RAW даёт только атрибут файла `/usr/sbin/arping`
```bash
kubectl exec no-drop-pod -- setpriv --reuid=1000 --regid=1000 --clear-groups arping -c1 -w2 -I eth0 "$GW"
```

## 5. Контроль: без атрибута команда не работает

На поде `no-drop-pod` файл `/tmp/arping-copy` является копией без атрибута. От того же uid 1000 команда завершается отказом
```bash
kubectl exec no-drop-pod -- cp /usr/sbin/arping /tmp/arping-copy
kubectl exec no-drop-pod -- getcap /tmp/arping-copy
kubectl exec no-drop-pod -- setpriv --reuid=1000 --regid=1000 --clear-groups /tmp/arping-copy -c1 -w2 -I eth0 "$GW"
```

## 6. Атрибут против пустого ограничивающего набора

На поде `no-drop-pod` наборы capabilities процесса снимаются вручную. Ядро не запускает файл `/usr/sbin/arping`, вызов execve возвращает EPERM
```bash
kubectl exec no-drop-pod -- setpriv --bounding-set=-all --inh-caps=-all --ambient-caps=-all arping -c1 -w2 -I eth0 "$GW"
```

## 7. Capability возвращена в под

На поде `add-pod` после `drop: [ALL]` в набор capabilities возвращён NET_RAW через `add`. Атрибут файла не нужен
```bash
kubectl exec add-pod -- arping -c1 -w2 -I eth0 "$GW"
```

## 8. Удалить поды

Удалить поды по манифесту `pods.yaml`
```bash
kubectl delete -f pods.yaml
```
