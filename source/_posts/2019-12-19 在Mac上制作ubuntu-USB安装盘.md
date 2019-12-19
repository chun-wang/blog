---
title: 在Mac上制作ubuntu USB安装盘
category:
  - 工具
tags:
  - ubuntu
toc: true
date: 2019-12-19 08:37:49
---

### 1. 制作系统`img`

```bash
# 转换命令
$ hdiutil convert -format UDRW -o ubuntu-18-04.img ubuntu-18.04-desktop-amd64.iso
```

### 2. 查看`U盘`挂载的目录

比如我这边挂载的路径是 /dev/disk2

```bash
$ diskutil list 
...
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *31.7 GB    disk2
   1:             Windows_FAT_32 NICE                    31.0 GB    disk2s1
...
```

### 3. 取消 `U盘` 的挂载（不要拔掉）

```bash
$ diskutil unmountDisk /dev/disk2
```

### 4. 写入 `U盘`

**注意:**此处是 `rdisk2`而不是 `disk2`，执行命令后大约等待个10分钟左右，中途不管终端是否有显示，不要直接`ctrl + C`退出或拔出`U盘`。

```bash
$ sudo dd if=ubuntu-18-04.img.dmg of=/dev/rdisk2 bs=1m
```