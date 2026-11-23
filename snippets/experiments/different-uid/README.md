# Чтение окружения при разных uid, оба не root

## Что проверяем

Два пода на одном узле. Секрет `different-uid` создаёт этот каталог. Оба пода запускаются с `runAsNonRoot: true`.

`secret-different-uid` запускается с `runAsUser: 1000` и получает ключ Secret `password` в окружение через `envFrom`. Процесс читает файл `/tmp/different-uid`.

`hostpid-uid2000` запускается с `hostPID: true` и `runAsUser: 2000`. Поле `privileged` не задано.

## Результат

Процесс от uid `2000` видит процесс пода `secret-different-uid` и читает его командную строку. Файл `/proc/<pid>/environ` этого процесса ядро не открывает: `Permission denied`.
