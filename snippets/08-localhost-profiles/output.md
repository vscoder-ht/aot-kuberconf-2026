Записанный вывод доставки профилей Localhost. Показывать, если стенд не отвечает.

Один и тот же манифест. Каталог файла seccomp на обоих узлах — `/var/lib/kubelet/seccomp`. 20 ноября 2026.

## Управляемый кластер

Kubernetes `v1.35.1`, containerd `2.2.1`, узел Ubuntu 22.04.5.
Контекст `yc-stand-mk8s`, пространство имён `default`.

Оба DaemonSet стали Ready. Поды проверки в `Running`:

```bash
$ kubectl get pods -l case=localhost-profiles
NAME                               READY   STATUS    RESTARTS   AGE
apparmor-localhost                 1/1     Running   0          2s
apparmor-profile-installer-rn8dt   1/1     Running   0          11s
seccomp-localhost                  1/1     Running   0          2s
seccomp-profile-installer-zj2nr    1/1     Running   0          11s
```

На поде `seccomp-localhost` фильтр установлен.

```bash
$ grep ^Seccomp /proc/1/status
Seccomp:	2
Seccomp_filters:	1
```

На поде `apparmor-localhost` загружен профиль `kuberconf-localhost`.

```bash
$ cat /proc/1/attr/current
kuberconf-localhost (enforce)
```

## k3s

k3s `v1.34.12+k3s1`, containerd `2.2.7-k3s1`, узел Ubuntu 24.04.5, ядро `6.8.0-149-generic`.
Контекст `default`, пространство имён `default`. Машина GitLab каталога `base/yandex-mk8s`.

Оба DaemonSet стали Ready. Поды проверки в `Running`:

```bash
$ kubectl get pods -l case=localhost-profiles
NAME                               READY   STATUS    RESTARTS   AGE
apparmor-localhost                 1/1     Running   0          2s
apparmor-profile-installer-g97z7   1/1     Running   0          43s
seccomp-localhost                  1/1     Running   0          2s
seccomp-profile-installer-z9s65    1/1     Running   0          43s
```

На поде `seccomp-localhost` фильтр установлен.

```bash
$ grep ^Seccomp /proc/1/status
Seccomp:	2
Seccomp_filters:	1
```

На поде `apparmor-localhost` загружен профиль `kuberconf-localhost`. Парсер AppArmor на узле — `4.0.1`.

```bash
$ cat /proc/1/attr/current
kuberconf-localhost (enforce)
```

Поды и DaemonSet на обоих кластерах удалены. Файл в `/var/lib/kubelet/seccomp` и профиль AppArmor в ядре узла эта команда не снимает; повторно их наличие не проверялось.

## Имя профиля AppArmor отсутствует в ядре

Тот же день. Под `apparmor-missing`, `appArmorProfile.type: Localhost`, `localhostProfile: kuberconf-missing`. Имени в ядре нет. На управляемом кластере и на k3s фаза `Pending`, причина `CreateContainerError`:

```text
failed to get container spec opts: failed to generate apparmor spec opts: apparmor profile not found kuberconf-missing
```

Под после проверки удалён.

## Вызовы сборки

22 ноября 2026. Управляемый кластер, тот же контекст `yc-stand-mk8s`. Файл `kuberconf-pivot-root.json` заменён: список `RuntimeDefault` containerd 2.2.1 для amd64, к нему добавлены `mount` и `pivot_root`. На узле в файле есть эти два имени, строк `unshare` и `umount2` нет.

Под `seccomp-localhost` после повторного копирования файла в `Running`. В `/proc/1/status` поле `Seccomp` равно `2`.

Отдельный под `seccomp-filter-check`: capability `SYS_ADMIN`, AppArmor `Unconfined`, тот же профиль seccomp. Capability нужна, чтобы отказ ядра по праву не скрыл решение фильтра.

```text
unshare: unshare(0x20000): Operation not permitted
unshare_exit:1
mount_probe_exit:0
umount: can't unmount /tmp/umount-probe: Operation not permitted
umount_probe_exit:1
mount_exit:0
pivot_exit:0
```

`mount` типа `tmpfs` и `pivot_root` завершились с кодом 0. `unshare` нового пространства монтирования и `umount` того же tmpfs фильтр отклонил: `Operation not permitted`. Каталог `put_old` создан после `mount`. Под после проверки удалён. Поды доставки и оба DaemonSet на этом кластере тоже удалены. k3s этим прогоном не проверялся.

Тот же день, повтор после добавления `umount2`. Файл на узле содержит `umount2` и `pivot_root`, строки `unshare` нет. Под `seccomp-filter-check` с теми же `SYS_ADMIN` и AppArmor `Unconfined`:

```text
unshare: unshare(0x20000): Operation not permitted
unshare_exit:1
mount_exit:0
umount_exit:0
pivot_exit:0
```

`umount` того же tmpfs завершился с кодом 0. `unshare` по-прежнему отклоняется. Под и оба DaemonSet после проверки удалены.
