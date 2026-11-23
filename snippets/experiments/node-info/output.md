Просмотр сведений узла. 23 ноября 2026. Управляемый кластер, Kubernetes `v1.35.1`, контекст `yc-stand-mk8s`, пространство имён `default`. Под `node-info` — uid `0`, `id` даёт `uid=0(root)`. Под `node-info-1000` — `runAsNonRoot: true`, `runAsUser: 1000`, `runAsGroup: 1000`, `id` даёт `uid=1000 gid=1000`. Поле `privileged` не задано, том узла не задан, поле `hostUsers` не задано. Оба пода удалены после команд.

```text
-r--------    1 root     root             0 Nov 23 20:40 /proc/slabinfo
-r--------    1 root     root          4096 Nov 23 20:40 /sys/class/dmi/id/board_serial
-r--------    1 root     root          4096 Nov 23 20:40 /sys/class/dmi/id/chassis_serial
-r--------    1 root     root          4096 Nov 23 20:40 /sys/class/dmi/id/product_serial
-r--------    1 root     root          4096 Nov 23 20:40 /sys/class/dmi/id/product_uuid
== /sys/class/dmi/id/product_uuid
<опущено>
== /sys/class/dmi/id/product_serial
<опущено>
== /sys/class/dmi/id/board_serial
<опущено>
== /sys/class/dmi/id/chassis_serial
xeon-gold-6338
== /proc/slabinfo
slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
ovl_inode          10821  11220    728   22    4 : tunables    0    0    0 : slabdata    510    510      0
rpc_inode_cache       23     23    704   23    4 : tunables    0    0    0 : slabdata      1      1      0
nf_conntrack         295    324    320   12    1 : tunables    0    0    0 : slabdata     27     27      0
ext4_groupinfo_4k    525    525    192   21    1 : tunables    0    0    0 : slabdata     25     25      0
btrfs_delayed_node      0      0    312   13    1 : tunables    0    0    0 : slabdata      0      0      0
btrfs_ordered_extent      0      0    424   19    2 : tunables    0    0    0 : slabdata      0      0      0
btrfs_extent_map       0      0    144   28    1 : tunables    0    0    0 : slabdata      0      0      0
btrfs_trans_handle      0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
btrfs_inode            0      0   1208   13    4 : tunables    0    0    0 : slabdata      0      0      0
fsverity_info          0      0    256   16    1 : tunables    0    0    0 : slabdata      0      0      0
fscrypt_info           0      0    136   30    1 : tunables    0    0    0 : slabdata      0      0      0
MPTCPv6               16     16   2048   16    8 : tunables    0    0    0 : slabdata      1      1      0
request_sock_subflow_v6      0      0    384   21    2 : tunables    0    0    0 : slabdata      0      0      0
```

Файл `/proc/slabinfo` целиком — 175 строк. Кэшей 173: строка версии и строка заголовка кэшами не являются. У `cred_jar` размер объекта 192 байта, у `kmalloc-192` тот же размер:

```text
cred_jar             791    924    192   21    1 : tunables    0    0    0 : slabdata     44     44      0
kmalloc-192        18476  19530    192   21    1 : tunables    0    0    0 : slabdata    930    930      0
```

От uid `0` файл открывается: `product_uuid` равен `<опущено>`, первая строка `/proc/slabinfo` — `slabinfo - version: 2.1`.

От uid `1000` режим в `ls -l` тот же, `0400`, владелец `root`. Чтение всех пяти файлов:

```text
cat: can't open '/sys/class/dmi/id/product_uuid': Permission denied
cat: can't open '/sys/class/dmi/id/product_serial': Permission denied
cat: can't open '/sys/class/dmi/id/board_serial': Permission denied
cat: can't open '/sys/class/dmi/id/chassis_serial': Permission denied
cat: can't open '/proc/slabinfo': Permission denied
```
