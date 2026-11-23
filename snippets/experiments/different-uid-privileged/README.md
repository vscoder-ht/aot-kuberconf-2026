# Чтение окружения при разных uid и privileged у читателя

## Что проверяем

Два пода на одном узле. Секрет `different-uid-privileged` создаёт этот каталог. Оба пода запускаются с `runAsNonRoot: true`.

`secret-privileged-uid` запускается с `runAsUser: 1000` и получает ключ Secret `password` в окружение через `envFrom`. Процесс читает файл `/tmp/different-uid-privileged`.

`hostpid-privileged` запускается с `hostPID: true`, `privileged: true` и `runAsUser: 2000`.

## Результат

Процесс читателя идёт от uid `2000`. `CapEff` равен `0000000000000000`. Командная строка процесса пода `secret-privileged-uid` читается. Файл `/proc/<pid>/environ` этого процесса ядро не открывает: `Permission denied`.
