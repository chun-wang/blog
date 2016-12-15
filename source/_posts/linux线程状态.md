---
layout: post
title:  "Linux线程状态"
date:   2014-12-09 15:54:29
category:
    - OS
tag:
    - Linux
    - Thread
---

Linux任务状态列表：

    D    不可中断 Uninterruptible sleep (usually IO)
    R    正在运行，或在队列中的进程
    S    处于休眠状态
    T    停止或被追踪
    Z    僵尸进程
    W    进入内存交换（从内核2.6开始无效）
    X    死掉的进程

    <    高优先级
    N    低优先级
    L    有些页被锁进内存
    s    包含子进程
    +    位于后台的进程组
    l    多线程，克隆线程

常见问题：

1、任务一直处在D状态：内核提供了HungTask功能用于监控线程在D状态不退出，通常任务进入D状态主要是做IO也就是外部设备操作，问题可能在相关的驱动代码bug。
