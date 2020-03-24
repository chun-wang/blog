---
title: Beyond Compare自动化脚本
category:
  - 工具
tags:
  - beyond compare
toc: true
date: 2020-03-24 20:11:45
---

##### 命令样例

windows下使用`bcompare.exe`,Linux下可执行文件为`bcompare`

~~~ bash
# 说明：
# bcompare: beyond compare可执行文件
# "@/path/scripts.txt": 脚本路径，以`@`开头
# "/folder1"：对应脚本内的参数一(%1)
# "/folder2"：对应脚本内的参数二(%2)
# "output.html"：对应脚本内的参数三(%3)

bcompare "@/path/scripts.txt" "/folder1" "/folder2" "output.html"
~~~

##### 官方脚本配置项查看

https://www.scootersoftware.com/v4help/index.html?scripting_reference.html

##### 官方脚本样例样例

https://www.scootersoftware.com/v4help/index.html?sample_scripts.html

##### 脚本样例

~~~bash
criteria rules-based follow-symlinks
load %1 %2
filter "-.git/;-.repo/"
expand all
select all.files
compare rules-based
collapse all
folder-report &
layout:side-by-side options:display-all,column-timestamp,column-size,column-attributes &
title:report-title &
output-to:%3 output-options:html-color
~~~