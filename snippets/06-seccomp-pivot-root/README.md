# Отказ seccomp RuntimeDefault на unshare

## Что проверяем

Три пода от root. Поле `capabilities` не задано, AppArmor снят (`Unconfined`). У первых двух различается `seccompProfile`. У третьего поле не задано.

Проверка — один `kubectl exec` на под. Внутри одна цепочка. Отдельный `exec` на каждый шаг не подходит: процесс `unshare` с завершением уничтожает созданные пространства, а `pivot_root` в пространстве монтирования пода сменил бы корень контейнера до показа.

```bash
unshare -Urm sh -c 'mkdir -p /tmp/newroot && mount -t tmpfs tmpfs /tmp/newroot && mkdir -p /tmp/newroot/old && pivot_root /tmp/newroot /tmp/newroot/old'
```

Шаги внутри этой строки, по порядку. Соединение `&&`: при отказе шага следующие не выполняются.

1. `unshare -Urm` запускает `sh -c` в новых пространствах.
   - `-U` — новое пространство пользователей, флаг `CLONE_NEWUSER` (`0x10000000`).
   - `-r` — карта идентификаторов: root пода становится root этого пространства. Процесс пода и так `uid 0`, BusyBox записывает карту сам. `newuidmap` команда не вызывает.
   - `-m` — новое пространство монтирования, флаг `CLONE_NEWNS` (`0x20000`). `pivot_root` меняет корень только в нём.
   - Вместе аргумент вызова `0x10020000`. На `RuntimeDefault` отказ называет его: `unshare: unshare(0x10020000): Operation not permitted`. Оболочка `sh -c` при этом не стартует.
2. `mkdir -p /tmp/newroot` создаёт точку будущего монтирования. Каталог нужен до `mount`.
3. `mount -t tmpfs tmpfs /tmp/newroot` подключает tmpfs на эту точку. Для `pivot_root` новый корень должен быть отдельной точкой монтирования. Источник в команде тоже `tmpfs`: у tmpfs нет устройства.
4. `mkdir -p /tmp/newroot/old` создаёт каталог `put_old` уже на новом tmpfs. Каталог, созданный на старом корне заранее, этот tmpfs закрывает, и `pivot_root` его не видит.
5. `pivot_root /tmp/newroot /tmp/newroot/old`. Первый аргумент — новый корень. Второй — куда сложить прежний. После вызова прежний корень процесса доступен как `/old`.

На `Unconfined` и при пустом поле цепочка завершается с кодом 0. Корень пода, процесс `sleep`, остаётся `/`: `pivot_root` прошёл в дочернем пространстве монтирования и с завершением `unshare` исчез.

У `seccomp-runtime-default` задано `seccompProfile.type: RuntimeDefault`. `unshare` завершается отказом `Operation not permitted`, сообщение `unshare: unshare(0x10020000)`. До `mount` и `pivot_root` выполнение не доходит. В `/proc/1/status` поле `Seccomp` равно `2`, `Seccomp_filters` равно `1`. `CapEff` равен `00000000a80425fb`: бита `SYS_ADMIN` нет.

В `RuntimeDefault` containerd 2.2.1 вызовы `unshare`, `mount` и `umount2` разрешены, только если в ограничивающем наборе есть `CAP_SYS_ADMIN`. В кейсе этого права нет. `pivot_root` в список разрешённых не входит и при наличии `CAP_SYS_ADMIN`.

У `seccomp-unconfined` задано `seccompProfile.type: Unconfined`. Та же команда завершается с кодом 0. `pivot_root` меняет корень процесса внутри нового пространства монтирования. Корень пода остаётся `/`. В `/proc/1/status` поле `Seccomp` равно `0`, `Seccomp_filters` равно `0`: фильтр не установлен. `CapEff` тот же. Право `SYS_ADMIN` есть у процесса внутри нового пространства пользователей и в набор пода не входит.

У `seccomp-unset` поле `seccompProfile` не задано. API его не дописывает, аннотации seccomp нет. В `/proc/1/status` те же `Seccomp` `0` и `Seccomp_filters` `0`. Та же команда завершается с кодом 0. Это не `RuntimeDefault`: у того `Seccomp` равно `2`, фильтр один, `unshare` даёт `Operation not permitted`.

## Зачем

Показать путь в корень образа без `CAP_SYS_ADMIN`. Сборщик, который монтирует в собственном пространстве пользователей, начинает с `unshare`. На `RuntimeDefault` профиль режет этот вызов по номеру. Шаг не доходит до `mount` и `pivot_root`.

Docker Build, BuildKit и nerdctl build от root входят в этот корень через runc: сначала `mount`, затем `pivot_root`. Тот же вход без права на узле начинается с `unshare`. Кейс вызывает эту последовательность в контейнере. Dockerfile не обязателен: отказ ядра тот же.

Под при этом в `Running`. runc узла входит в корень контейнера, и только потом ядро включает фильтр. Сборка идёт позже: её процесс — уже процесс этого контейнера, фильтр на нём действует, и `unshare` ядро не пропускает.

AppArmor у всех снят: иначе отказ `deny mount` смешается с отказом фильтра.

Прогон 23 ноября 2026 на управляемом кластере, Kubernetes `v1.35.1`, containerd `2.2.1`. Три пода после команд удалены.
