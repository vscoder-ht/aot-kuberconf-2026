# Сокращённый фрагмент шаблона RuntimeDefault.
# Снят из /usr/bin/containerd v2.2.1 на узле стенда.
# В ядре профиль загружен как cri-containerd.apparmor.d (enforce).
# Исходника на диске узла нет, в sysfs — скомпилированный блоб.
#
# Действия в правилах файла:
#   r — чтение
#   w — запись
#   k — блокировка
#   l — создание ссылки
#   x — исполнение

profile cri-containerd.apparmor.d flags=(attach_disconnected,mediate_deleted) {
  network,                              # разрешено: все семейства, типы и протоколы сокетов
  capability,                           # разрешено: все capabilities
  file,                                 # разрешено: доступ к файлам
  umount,                               # разрешено: отмонтирование

  deny @{PROC}/* w,                     # запрещено: запись в файлы прямо в /proc, не в подкаталогах
  deny @{PROC}/sys/[^k]** w,            # запрещено: запись в /proc/sys, кроме путей на k* (kernel)
  deny @{PROC}/sysrq-trigger rwklx,     # запрещено: все действия — sysrq-trigger (SysRq, в том числе перезагрузка узла)
  deny @{PROC}/mem rwklx,               # запрещено: все действия — /proc/mem
  deny @{PROC}/kmem rwklx,              # запрещено: все действия — виртуальная память ядра
  deny @{PROC}/kcore rwklx,             # запрещено: все действия — образ памяти ядра

  deny mount,                           # запрещено: любое монтирование

  deny /sys/firmware/** rwklx,          # запрещено: все действия — прошивки
  deny /sys/kernel/security/** rwklx,   # запрещено: все действия — securityfs

  # разрешено: ptrace только к процессам того же профиля
  ptrace (trace,tracedby,read,readby) peer=cri-containerd.apparmor.d,
}
