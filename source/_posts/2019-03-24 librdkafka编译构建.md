---
title: librdkafka编译构建
category:
  - Develop
  - 工具
tags:
  - kafka
toc: true
date: 2019-03-24 16:36:40
---

##### 版本获取

https://github.com/edenhill/librdkafka/releases

##### 构建命令

~~~bash
export LIBS="-lssl -lcrypto"
export CPATH=/opt/tools/openssl/include
./configure --prefix=/opt/tools/librdkafka --LDFLAGS="-L/opt/tools/openssl/lib" --mbits=32
make
make install
~~~

##### 支持32位

~~~ bash
--mbits=32
~~~

##### 支持SSL

官方说明：https://github.com//edenhill/librdkafka/wiki/Using-SSL-with-librdkafka

有时候项目中会采用自定义的库目录放置openssl，如果有类似诉求，可以做如下设置

1. 添加openssl头文件包含路径(其中**OPENSSL__INCLUDE**为头文件路径)

   ~~~ bash
   export CPATH=$CPATH:$OPENSSL_INCLUDE
   ~~~

2. configure时添加LDFLAGS参数或将LDFLAGS导出为环境变量(其中**OPENSSL_LIB_PATH**为库所在路径)，以下方法二选一即可。

   ~~~bash
   a. --LDFLAGS="-L$OPENSSL_LIB_PATH"
   b. export LDFLAGS="_L$OPENSSL_LIB_PATH"
   ~~~

当前获取的librdkafka包在使用openssl时存在一个BUG，由于SSL库链接顺序问题导致example里面的代码链接出错，具体解决情况可以跟踪官方ISSUE：https://github.com//edenhill/librdkafka/issues/1576    这里给出一个规避方案：在编译时配置LIBS环境变量，强制覆盖SSL库的顺序

~~~bash
export LIBS="-lssl -lcrypto"
~~~

