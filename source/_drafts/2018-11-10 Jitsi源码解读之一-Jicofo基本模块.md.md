---
title: 'Jitsi源码解读之一:Jicofo基本模块'
category:
  - Develop
tags:
  - Jitsi
  - Jicofo
  - 架构
date: 2018-11-10 23:02:25
---

#### FocusComponent

将Jicofo封装为XMPP的一个扩展插件，主要起到如下几个作用：

1. 作为插件注册到XMPP服务器，侦听分发来自XMPP的消息
2. 通过XMPP的PubSub机制发现Jitsi相关组件，包括videobridge/jbri/jigasi等

#### ComponentsDiscovery

```
* Class observes components available on XMPP domain, classifies them as JVB,
* SIP gateway or Jirecon and notifies {@link JitsiMeetServices} whenever new
* instance becomes available or goes offline.
```

侦听、发现XMPP组件在线状态，主要包括：**JVB**、**Jigasi**(SIP gateway)和**Jirecon**等，将在线状态通告给JitsiMeetServices负责管理。



#### AbstractChannelAllocator

```
* A task which allocates Colibri channels and (optionally) initiates a
* Jingle session with a participant.
```

通道申请器，会创建两个通道：

1. RTP数据通信通道（Colibri channels）
2. 服务器和客户端间的信令通道（Jingle session）

里面分别用到了xmpp的两个扩展，具体可以参考：[XEP-0340: COnferences with LIghtweight BRIdging (COLIBRI)](https://xmpp.org/extensions/xep-0340.html)和[XEP-0166: Jingle](https://xmpp.org/extensions/xep-0166.html)、[XEP-0167: Jingle RTP Sessions](https://xmpp.org/extensions/xep-0167.html)。






