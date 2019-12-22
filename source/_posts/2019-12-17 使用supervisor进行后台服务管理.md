---
title: 使用supervisor进行后台服务管理
category:
  - 工具
tags:
  - ddns
toc: true
date: 2019-12-17 22:24:45
---

### 介绍

官方网址：http://supervisord.org

Supervisor is a client/server system that allows its users to monitor and control a number of processes on UNIX-like operating systems.

It shares some of the same goals of programs like [*launchd*](http://supervisord.org/glossary.html#term-launchd), [*daemontools*](http://supervisord.org/glossary.html#term-daemontools), and [*runit*](http://supervisord.org/glossary.html#term-runit). Unlike some of these programs, it is not meant to be run as a substitute for `init` as “process id 1”. Instead it is meant to be used to control processes related to a project or a customer, and is meant to start like any other program at boot time.

### 安装

```bash
sudo apt install supervisor
```

启动服务

```bash
service supervisor start
```

停止服务

```bash
# 方式一
service supervisor stop

# 方式二
supervisorctl shutdown
```

### 使用SUPERVISOR

#### 查询帮助

```bash
# 帮助命令
supervisorctl help

# 查询结果
default commands (type help <topic>):
=====================================
add    exit      open  reload  restart   start   tail   
avail  fg        pid   remove  shutdown  status  update 
clear  maintail  quit  reread  signal    stop    version
```

#### 查询版本

~~~bash
supervisorctl version
~~~

查询可操作的服务

~~~bash
# 命令
supervisorctl avail

# 输出样例
frps                             in use    auto      999:999
~~~

#### 重新加载配置文件

~~~bash
# 命令
supervisorctl reread
~~~



#### 启动服务

```bash
# 启动指定服务
supervisorctl start [name:配置文件中配置的名字]

# 启动所有服务
supervisorctl start all

# 启动进程组
supervisorctl start <gname>:*

# 同时启动多个服务
supervisorctl start <name1> <name2>
```

#### 停止服务

```bash
# 停止指定服务
supervisorctl stop [name:配置文件中配置的名字]

# 停止所有服务
supervisorctl stop all

# 停止进程组
supervisorctl stop <gname>:*

# 同时停止多个服务
supervisorctl stop <name1> <name2>
```

#### 查询服务状态

```bash
# 查询命令
supervisorctl status

# 输出结果:
frp                              RUNNING   pid 17601, uptime 0:05:48
```

### 配置

#### 配置文件路径

```bash
# 配置文件根路径
/etc/supervisor/
# 根配置文件, 一般不做修改
/etc/supervisor/supervisord.conf
# 子配置文件路径，新增应用配置放置到此路径, 根配置文件会引用(include)该目录下的所有配置文件
/etc/supervisor/conf.d/
```

#### 手动生成配置文件

如果安装后的版本没有自动创建上述目录和配置文件，也可以自行手动创建

~~~bash
mkdir -p /etc/supervisor/conf.d
echo_supervisord_conf > /etc/supervisor/supervisord.conf
~~~

在配置文件末尾修改引用自定义路径

~~~bash
[include]
files = /etc/supervisor/conf.d/*.conf
~~~



#### 配置文件规则

```bash
[program:frp] ;程序名称:终端控制时需要的标识
command=frps ; 运行程序的命令
directory=/root/frp/ ; 命令执行的目录
autorestart=true ; 程序意外退出是否自动重启
stderr_logfile=/var/log/frps.err.log ; 错误日志文件
stdout_logfile=/var/log/frps.out.log ; 输出日志文件
environment=ENVIRONMENT=Production ; 进程环境变量
user=root ; 进程执行的用户身份
stopsignal=INT ; 进程停止信号
```

#### frps配置样例

新增frps的配置文件

```bash
touch /etc/supervisor/conf.d/frps.conf
```

文件内容

```bash
[program:frps]
command = /root/frp/frps -c /root/frp/frps.ini
autostart = true
stderr_logfile=/var/log/frps.err.log 
stdout_logfile=/var/log/frps.out.log
```

重启supervisor服务

```bash
service supervisor restart
```

