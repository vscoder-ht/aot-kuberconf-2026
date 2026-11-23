Проверка профиля `buildkit.json` на управляемом кластере. 23 ноября 2026. Контекст `yc-stand-mk8s`, пространство имён `default`. Образ `moby/buildkit:v0.35.1-rootless`. Флаг демона `--oci-worker-no-process-sandbox`. Контекст контейнера совпадает с Helm-релизом rootless, профиль seccomp — `Localhost`, поле `localhostProfile` — `buildkit.json`. Файл на узле — `/var/lib/kubelet/seccomp/buildkit.json`.

## AppArmor

Тот же под и тот же профиль seccomp.

`appArmorProfile.type: RuntimeDefault`. Под стартовал и завершился с кодом 1:

```text
[rootlesskit:child ] error: failed to share mount point: /: permission denied
[rootlesskit:parent] error: child exited: exit status 1
could not connect to unix:///run/user/1000/buildkit/buildkitd.sock after 10 trials
```

Затем профиль `buildkit` загружен DaemonSet `buildkit-apparmor-installer`. У пода `appArmorProfile.type: Localhost`, `localhostProfile: buildkit`. Под завершился с фазой `Succeeded`. Шаг `RUN echo ok` прошёл, в журнале есть строка `BUILD_OK`.

## Seccomp, AppArmor снят

AppArmor в этом прогоне — `Unconfined`. Под `buildkit-seccomp-check` завершился с фазой `Succeeded`. Шаг `RUN echo ok` прошёл, в журнале есть строка `BUILD_OK`.

Прогоны 22 ноября шли с именем `kuberconf-buildkit.json` и тем же содержимым профиля.

Первый прогон, в профиле `clone` только без флагов нового пространства:

```text
[rootlesskit:parent] error: failed to start the child: fork/exec /proc/self/exe: operation not permitted
```

Второй прогон, `clone` разрешён с флагами нового пространства. Шаг `RUN` остановился в `runc`:

```text
runc run failed: unable to start container process: error during container init: sethostname: operation not permitted
```

Третий прогон, в профиль добавлены `sethostname` и `setdomainname`. Под `buildkit-seccomp-check` завершился с фазой `Succeeded`. Шаг `RUN echo ok` прошёл, в журнале есть строка `BUILD_OK`.
