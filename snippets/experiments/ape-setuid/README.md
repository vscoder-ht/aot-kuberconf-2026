# allowPrivilegeEscalation и бит setuid

Прогон 22 ноября 2026 на управляемом кластере, Kubernetes `v1.35.1`. Вывод — [output.md](output.md). В показ не входит.

## Что проверяем

Два пода из образа `archlinux`. Оба запускаются от uid `0`. Поле `privileged` не задано.

`ape-true`: `allowPrivilegeEscalation: true`.

`ape-false`: `allowPrivilegeEscalation: false`. Это выставляет контейнеру `no_new_privs`.

В каждом поде корневой файл `/root/token` получает режим `0600`. Копия `/usr/bin/cat` получает владельца `root` и бит setuid. Дальше процесс от uid `1000` запускает эту копию и читает `/root/token`.

Образ `archlinux` выбран потому, что `/usr/bin/cat` — отдельный файл coreutils. В `busybox` `cat` является ссылкой на общий двоичный файл, и бит setuid встал бы на все команды сразу.

## Результат

У `ape-true` `NoNewPrivs` равен `0`. Копия `cat` с битом setuid, запущенная от uid `1000`, получает эффективный uid `0` и читает `/root/token`. `CapEff` равен `00000000a80425fb`.

У `ape-false` `NoNewPrivs` равен `1`. Та же команда остаётся uid `1000`, `CapEff` равен `0000000000000000`, ядро возвращает `Permission denied`.

В параметрах корня нет `nosuid`. Пространство пользователей и `hostUsers` в этой паре не различаются. Файловые capabilities проходят тем же путём `no_new_privs`; эта проверка смотрит только бит setuid. Кейс `snippets/05-file-capabilities/` это поле не переключает.
