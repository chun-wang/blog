---
title: Mac使用ffmpeg转换DTS音频
category:
  - Develop
tags:
  - Mac
toc: true
date: 2019-11-09 10:36:40
---

#### 安装Homebrew（已经安装可跳过）

操作：

1. 启动终端程序(应用程序 －> 实用工具 －> 终端 ）
2. 安装brew.

安装命令：

~~~bash
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
~~~

#### 安装ffmpeg

安装命令：

~~~bash
brew install ffmpeg
~~~

#### 使用ffmpeg转换DTS音频

1. 转为双音轨的苹果无损格式：

   ~~~bash
   for file in *.wav; do name=$(echo $file | sed "s/\\.wav//g"); ffmpeg -acodec dts -i "$name".wav -vn -sn -ac 2 -acodec alac "$name".m4a; done
   ~~~


转换完毕后，将同目录下找到.m4a 的文件，导入iTunes.

2. 转为保留全部音轨（6.1）的 flac 格式：

   ~~~bash
   for file in *.wav; do name=$(echo $file | sed "s/\\.wav//g"); ffmpeg -acodec dts -i "$name".wav -vn -sn -acodec flac "$name".flac; done
   ~~~
