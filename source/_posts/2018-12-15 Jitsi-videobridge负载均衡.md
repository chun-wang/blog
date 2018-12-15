---
title: Jitsi-videobridge负载均衡
category:
  - Develop
tags:
  - Jitsi
  - 负载均衡
toc: true
date: 2018-12-15 22:27:52
---

#### 背景

本文主要解决两个问题：

1. 支持单中心多videobridge，实现媒体流的负载均衡和能力扩展。
2. 解决Jicofo默认的在线状态检查检测不到videobridge快速上下线问题[^1] 。

#### 官方参考

想要了解最新的配置方法，可以参考Jitsi官方的配置文档：

https://github.com/jitsi/jicofo/blob/master/doc/load_balancing.md

#### 配置Prosody支持发布

/etc/prosody/conf.d/example.cn.cfg.lua

1. 在modules_enabled中增加"pubsub"模块，使能订阅发布能力
2. 增加admins设置，在里面加上需要订阅、发布的videobridge(这样JVB才有权限创建PubSub节点)
3. 如果有多个videobridge，则一一在配置文件内添加即可

```lua
VirtualHost "example.cn"
		-- 中间省略
        modules_enabled = {
            "bosh";
            "pubsub";
            "ping"; -- Enable mod_ping
        }
		
        admins = {
            "jitsi-videobridge.example.cn"
        }

Component "jitsi-videobridge.example.cn"
    component_secret = "65EVA9o8"
```

#### 配置videobridge状态发布

修改配置文件`/etc/jitsi/videobridge/sip-communicator.properties`，其中PUBSUB_SERVICE为prosody上用于发布状态的Virtualhost，PUBSUB_NODE为状态发布到的节点名称，这两个字段必须和后面Jicofo的配置保持一致。

```properties
org.jitsi.videobridge.ENABLE_STATISTICS=true
org.jitsi.videobridge.STATISTICS_TRANSPORT=pubsub
org.jitsi.videobridge.PUBSUB_SERVICE=example.com
org.jitsi.videobridge.PUBSUB_NODE=sharedStatsNode
```

#### 配置jicofo订阅状态

修改配置文件`/etc/jitsi/jicofo/sip-communicator.properties`，这两项配置需要和上述videibridge内的配置保持一致，这样Jicofo才能正确订阅到videobridge发布的状态信息。

```properties
org.jitsi.focus.pubsub.ADDRESS=example.com
org.jitsi.jicofo.STATS_PUBSUB_NODE=sharedStatsNode
```

[^1]: Jicofo默认检查节点状态是定时查询xmpp上在线的Component，如果videobridge发生重启，首先会触发健康检查失败，Jicofo会感知videobridge下线。但如果videibridge在检查周期之前重新上线，检查器内保存的在线节点并不会有变化，因此也不会上报bridge上线的事件。