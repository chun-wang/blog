---
title: JDK多版本快速切换
category:
  - Develop
tags:
  - Java
  - JDK
date: 2016-12-15 23:23:54
---

    export JAVA_7_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_80.jdk/Contents/Home
    export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_31.jdk/Contents/Home
    export JAVA_HOME=$JAVA_7_HOME
    alias jdk7='export JAVA_HOME=$JAVA_7_HOME'
    alias jdk8='export JAVA_HOME=$JAVA_8_HOME'
