# Отказ AppArmor RuntimeDefault на mount

## Что проверяем

Три пода от root. У всех добавлен `SYS_ADMIN`, seccomp снят (`Unconfined`). У первых двух различается `appArmorProfile`. У третьего поле не задано.

Команды:

```bash
mkdir /tmp/newroot
mount -t tmpfs tmpfs /tmp/newroot
```

У `apparmor-runtime-default` задано `appArmorProfile.type: RuntimeDefault`. `mount` типа `tmpfs` завершается отказом `Permission denied`. В `/proc/1/attr/current` — `cri-containerd.apparmor.d (enforce)`.

У `apparmor-unconfined` задано `appArmorProfile.type: Unconfined`. Та же команда завершается с кодом 0. В `/proc/1/attr/current` — `unconfined`.

У `apparmor-unset` поле `appArmorProfile` не задано. API его не дописывает, аннотации AppArmor нет. В `/proc/1/attr/current` — `cri-containerd.apparmor.d (enforce)`, тот же профиль, что у `RuntimeDefault`. `mount` типа `tmpfs` завершается отказом `Permission denied`.

## Зачем

Показать, что на `RuntimeDefault` шаг сборки не подключит слой образа: профиль запрещает монтирование целиком (`deny mount`). Заблокированное действие даёт отказ ядра. Docker Build, BuildKit и nerdctl build подключают слой монтированием. Кейс вызывает тот же `mount` в контейнере задания. Dockerfile не нужен: отказ ядра тот же.

Под при этом в `Running`. runc узла входит в корень контейнера, и только потом ядро включает профиль. Сборка идёт позже: её монтирование — уже процесс этого контейнера, профиль на нём действует, и `mount` шага ядро не пропускает.

`SYS_ADMIN` добавлен всем трём подам. Команда здесь — прямой `mount`, без нового пространства пользователей. Без этого права ядро отвергает `mount` до AppArmor. Путь без `SYS_ADMIN` в наборе пода записан в `snippets/06-seccomp-pivot-root/`. Там `unshare` создаёт пространство пользователей. На `Unconfined` и при пустом поле `seccompProfile` `mount` проходит уже внутри него. На `RuntimeDefault` фильтр останавливает цепочку на `unshare`, до `mount` выполнение не доходит. seccomp у всех трёх подов этого кейса снят: иначе отказ фильтра смешается с отказом профиля.

Сниппет прогнан на управляемом кластере стенда, Kubernetes `v1.35.1`.
