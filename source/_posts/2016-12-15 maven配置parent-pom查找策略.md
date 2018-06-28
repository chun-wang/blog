---
title: maven配置parent pom查找策略
date: 2016-12-15 23:00:41
category:
    - Develop
tags:
    - Java
    - Maven
---

当我们在pom.xml中添加parent pom的时候，通常maven会按照如下顺序查找:

1. relativePath标签指向的路径。
2. 默认的relativePath路径"../"。
3. 本地maven仓库。
4. 远程maven仓库。

**注意事项:**

通常我们在maven的setting.xml文件中，直接配置mirrors到指定的服务器就可以方便的进行开发了。但是如果我们要引用远程仓库中的包作为parent，则必须将该远程仓库通过profile方式添加进来，光使用mirrors映射到该仓库是无效的。
