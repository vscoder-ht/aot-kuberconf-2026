# Чтение окружения читателем от uid 0

## Что проверяем

Два пода на одном узле. Секрет `reader-uid0` создаёт этот каталог.

`secret-reader-uid0` запускается с `runAsNonRoot: true` и `runAsUser: 1000`. Ключ Secret `password` попадает в окружение через `envFrom`. Процесс читает файл `/tmp/reader-uid0`.

`hostpid-uid0` запускается с `hostPID: true`, `privileged: false` и `runAsUser: 0`.

## Результат

Процесс читателя идёт от uid `0`. `CapEff` равен `00000000a80425fb`. Командная строка процесса пода `secret-reader-uid0` читается. Файл `/proc/<pid>/environ` этого процесса ядро не открывает: `Permission denied`.
