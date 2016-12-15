---
title: shell中的正则表达式
date: 2015-03-22 17:53:57
categories:
    -Develop
tags:
  - tools
  - shell
  - regexp
---

使用方法很简单,例如要测试表达式中只含有数字:

    [[ "1234" =~ ^[0-9]*$ ]]

为了更加清晰的知道结果, 我们可以这样：

    [[ "1234" =~ ^[0-9]*$ ]] && echo "true"

甚至这样:

    ([[ "1234" =~ ^[0-9]*$ ]] && echo "true")|| echo "false"

如果表达式成功则显示`true`,否则显示`false`