# Чтение окружения процессом от uid 1000

## Что проверяем

Два пода на одном узле. Секрет `reader-uid-1000` создаёт этот каталог.

`secret-uid0` получает ключ Secret `password` в окружение через `envFrom` и запускается от uid `0`. Поле `privileged` у него выключено. Процесс читает файл `/tmp/reader-uid-1000`.

`hostpid-noroot` запущен с `hostPID: true`, `runAsNonRoot: true` и `runAsUser: 1000`. Поле `privileged` не задано.

## Результат

Процесс от uid `1000` видит процесс пода `secret-uid0` и читает его командную строку. Файл `/proc/<pid>/environ` этого процесса ядро не открывает: `Permission denied`.
