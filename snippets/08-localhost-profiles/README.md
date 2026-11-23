# Доставка профилей Localhost

## Что проверяем

Два привилегированных DaemonSet и два пода.

`seccomp-profile-installer` копирует файл `kuberconf-pivot-root.json` в `/var/lib/kubelet/seccomp`. Этот каталог читает kubelet. У пода `seccomp-localhost` поле `seccompProfile.type` равно `Localhost`, `localhostProfile` — имя этого файла.

`apparmor-profile-installer` записывает профиль в `/etc/apparmor.d/kuberconf-localhost` и загружает его в ядро узла вызовом `apparmor_parser`. Для вызова нужен `hostPID`: процесс входит в пространство PID узла и запускает парсер узла. У пода `apparmor-localhost` поле `appArmorProfile.type` равно `Localhost`, `localhostProfile` — имя профиля в ядре, `kuberconf-localhost`.

Профиль seccomp собран из RuntimeDefault containerd 2.2.1 для amd64. Для сборки к набору добавлены `mount`, `umount2` и `pivot_root`. `umount2` снимает старый корень после `pivot_root`. Вызов `clone` разрешён, пока в флагах нет нового пространства имён. `clone3` возвращает `ENOSYS`. Действие по умолчанию — `SCMP_ACT_ERRNO`.

Профиль AppArmor повторяет шаблон containerd `cri-containerd.apparmor.d`: те же запреты записи в `/proc` и `/sys`. Вместо `deny mount` стоят правила `mount` и `pivot_root`.

Команды — в `snippet.md`. Результат прогона — в `output.md`.

## Зачем

Показать два разных места доставки. Файл seccomp лежит на диске узла, и его читает kubelet. Профиль AppArmor к этому моменту уже загружен в ядро: своего каталога у kubelet для него нет. Копирование файла, как для seccomp, профиль AppArmor в ядро не загружает.

Признак seccomp: под в `Running`, в `/proc/1/status` поле `Seccomp` равно `2`. У `Unconfined` это поле равно `0`. Если файла профиля на узле нет, под не стартует.

Признак AppArmor: в `/proc/1/attr/current` записано `kuberconf-localhost (enforce)`. У `RuntimeDefault` в этом файле `cri-containerd.apparmor.d (enforce)`. Если имени нет в ядре, под остаётся в `Pending`.

AppArmor у пода seccomp снят, seccomp у пода AppArmor снят: в каждом поде виден один профиль.

Удаление DaemonSet оставляет файл в `/var/lib/kubelet/seccomp` и профиль AppArmor в ядре узла.
