Команды доставки профилей seccomp и AppArmor сборщика и пода проверки. Пути в командах указаны относительно каталога сниппета.

Собрать ConfigMap из `profile.json` и применить DaemonSet.

```bash
export KUBECONFIG=../../../vsc-kuberconf-aot-2026-stand/base/yandex-mk8s/kubeconfig/mk8s.kubeconfig
kubectl create configmap buildkit-seccomp-profile \
  --from-file=buildkit.json=profile.json \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl label configmap buildkit-seccomp-profile case=buildkit-seccomp --overwrite
kubectl apply -f seccomp-daemonset.yaml
```

Дождаться, пока DaemonSet станет Ready. К этому моменту файл лежит в каталоге kubelet.

```bash
kubectl rollout status daemonset/buildkit-seccomp-installer
```

В случае правки `profile.json` обновить ConfigMap и перезаписать файл на узле.

```bash
kubectl create configmap buildkit-seccomp-profile \
  --from-file=buildkit.json=profile.json \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl rollout restart daemonset/buildkit-seccomp-installer
kubectl rollout status daemonset/buildkit-seccomp-installer
```

Загрузить профиль AppArmor в ядро и дождаться Ready.

```bash
kubectl apply -f apparmor-daemonset.yaml
kubectl rollout status daemonset/buildkit-apparmor-installer
```

В случае правки профиля в `apparmor-daemonset.yaml` обновить ConfigMap и заново загрузить профиль в ядро. Установщик вызывает `apparmor_parser` один раз при старте. Новый текст попадает в ядро после перезапуска пода установщика.

```bash
kubectl apply -f apparmor-daemonset.yaml
kubectl rollout restart daemonset/buildkit-apparmor-installer
kubectl rollout status daemonset/buildkit-apparmor-installer
```

Применить под проверки. Дождаться фазы Succeeded и снять журнал.

```bash
kubectl delete pod buildkit-seccomp-check --ignore-not-found
kubectl apply -f pod.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/buildkit-seccomp-check --timeout=180s
kubectl logs buildkit-seccomp-check
```

Удалить под и DaemonSet. Файл в `/var/lib/kubelet/seccomp`, копия `/etc/apparmor.d/buildkit` и профиль AppArmor в ядре узла остаются.

```bash
kubectl delete -f pod.yaml --ignore-not-found
kubectl delete -f seccomp-daemonset.yaml
kubectl delete -f apparmor-daemonset.yaml
kubectl delete configmap buildkit-seccomp-profile --ignore-not-found
```
