---
layout: post
title:  "Ruby工具"
date:   2015-01-14 15:54:29
category: 软件开发
---

###Ruby
Ruby语言解释、执行器

###RVM
用于帮你安装Ruby环境，帮你管理多个Ruby环境，帮你管理你开发的每个Ruby应用使用机器上哪个Ruby环境。Ruby环境不仅仅是Ruby本身，还包括依赖的第三方Ruby插件。都由RVM管理。

###Rails
基于RUBY语言的Web开发框架。[详细](http://zh.wikipedia.org/wiki/Ruby_on_Rails)

###RubyGems
Ruby程序包管理器（ package manager），类似RPM、yast。最新Ruby版本默认包含RubyGems了。

###Gem
Gem文件是封装起来的Ruby应用程序或代码库。
注：在终端下使用的gem命令，是RubyGems的客户端，用于安装、管理Gem包。

###Gemfile
定义应用依赖哪些GEM包，bundle根据该配置去寻找、安装GEM包。

###Rake
Rake是一门构建语言，和make类似。Rake是用Ruby写的，它支持自己的DSL用来处理和维护Ruby程序。 Rails用rake扩展来完成多种不容任务，如数据库初始化、更新等。[详细](http://rake.rubyforge.org/)

###Rakefile
Rakefile是由Ruby编写，Rake的命令执行就是由Rakefile文件定义。

In a gem’s context, the Rakefile is extremely useful. It can hold various tasks to help building, testing and debugging your gem, among all other things that you might find useful.
[详细](http://rake.rubyforge.org/files/doc/rakefile_rdoc.html)

###Bundle
相当于多个RubyGems批处理运行。在配置文件gemfilel里说明你的应用依赖哪些第三方包，他自动帮你下载安装多个包，并且会下载这些包依赖的包。

Bundler maintains a consistent environment for ruby applications. It tracks an application's code and the rubygems it needs to run, so that an application will always have the exact gems (and versions) that it needs to run.

###参考：
- [http://rake.rubyforge.org/](http://rake.rubyforge.org/)
- [http://rake.rubyforge.org/files/doc/rakefile_rdoc.html](http://rake.rubyforge.org/files/doc/rakefile_rdoc.html)
- [http://yinghuayuan8866.blog.163.com/blog/static/2245702720122909571/](http://yinghuayuan8866.blog.163.com/blog/static/2245702720122909571/)
- [http://martinfowler.com/articles/rake.html](http://martinfowler.com/articles/rake.html)
