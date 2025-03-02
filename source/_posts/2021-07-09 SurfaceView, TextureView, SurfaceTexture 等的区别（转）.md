---
title: SurfaceView, TextureView, SurfaceTexture 等的区别（转）
category:
  - 转载
tags:
  - Android
toc: true
date: 2021-07-09 20:11:45
---

>  原文地址 [juejin.cn](https://juejin.cn/post/6844903878450741262)

> SurfaceView, GLSurfaceView, SurfaceTexture 以及 TextureView 是 Android 当中名字比较绕，关系又比较密切的几个类。

SurfaceView, GLSurfaceView, SurfaceTexture 以及 TextureView 是 Android 当中名字比较绕，关系又比较密切的几个类。本文基于 Android 5.0(Lollipop) 的代码理一下它们的基本原理，联系与区别。
<!--more-->
SurfaceView
-----------

从 Android 1.0(API level 1) 时就有 。它继承自类 View，因此它本质上是一个 View。但**与普通 View 不同的是，它有自己的 Surface。**我们知道，一般的 Activity 包含的多个 View 会组成 View hierachy 的树形结构，只有最顶层的 DecorView，也就是根结点视图，才是对 WMS 可见的。这个 DecorView 在 WMS 中有一个对应的 WindowState。相应地，在 SF 中对应的 Layer。而 SurfaceView 自带一个 Surface，这个 Surface 在 WMS 中有自己对应的 WindowState，在 SF 中也会有自己的 Layer。如下图所示：

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c715bc16b?imageView2/0/w/1280/h/960/ignore-error/1)

也就是说，**虽然在 Client 端 (App) 它仍在 View hierachy 中，但在 Server 端（WMS 和 SF）中，它与宿主窗口是分离的。**这样的好处是对这个 Surface 的渲染可以放到单独线程去做，渲染时可以有自己的 GL context。这对于一些游戏、视频等性能相关的应用非常有益，因为它不会影响主线程对事件的响应。但它也有缺点，因为这个 Surface 不在 View hierachy 中，它的显示也不受 View 的属性控制，所以不能进行平移，缩放等变换，也不能放在其它 ViewGroup 中，一些 View 中的特性也无法使用。

### GLSurfaceView

从 Android 1.5(API level 3) 开始加入，作为 SurfaceView 的补充。它可以看作是 SurfaceView 的一种典型使用模式。在 SurfaceView 的基础上，它加入了 EGL 的管理，并自带了渲染线程。另外它定义了用户需要实现的 Render 接口，提供了用 Strategy pattern 更改具体 Render 行为的灵活性。作为 GLSurfaceView 的 Client，只需要将实现了渲染[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")的 Renderer 的实现类设置给 GLSurfaceView 即可。如：

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

相关类图如下。其中 SurfaceView 中的 SurfaceHolder 主要是提供了一坨操作 Surface 的接口。GLSurfaceView 中的 EglHelper 和 GLThread 分别实现了上面提到的管理 EGL 环境和渲染线程的工作。GLSurfaceView 的使用者需要实现 Renderer 接口。

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c4b9d3141?imageView2/0/w/1280/h/960/ignore-error/1)

SurfaceTexture
--------------

从 Android 3.0(API level 11) 加入。和 SurfaceView 不同的是，**它对图像流的处理并不直接显示，而是转为 GL 外部纹理，因此可用于图像流数据的二次处理（如 Camera 滤镜，桌面特效等）。**比如 Camera 的预览数据，变成纹理后可以交给 GLSurfaceView 直接显示，也可以通过 SurfaceTexture 交给 TextureView 作为 View heirachy 中的一个硬件加速层来显示。首先，SurfaceTexture 从图像流（来自 Camera 预览，视频解码，GL 绘制场景等）中获得帧数据，当调用 updateTexImage() 时，根据内容流中最近的图像更新 SurfaceTexture 对应的 GL 纹理对象，接下来，就可以像操作普通 GL 纹理一样操作它了。从下面的类图中可以看出，它核心管理着一个 BufferQueue 的 Consumer 和 Producer 两端。Producer 端用于内容流的源输出数据，Consumer 端用于拿 GraphicBuffer 并生成纹理。SurfaceTexture.OnFrameAvailableListener 用于让 SurfaceTexture 的使用者知道有新数据到来。JNISurfaceTextureContext 是 OnFrameAvailableListener 从 Native 到 Java 的 JNI 跳板。其中 SurfaceTexture 中的 attachToGLContext() 和 detachToGLContext() 可以让多个 GL context 共享同一个内容源。

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c4be0880c?imageView2/0/w/1280/h/960/ignore-error/1)

Android 5.0 中将 BufferQueue 的核心功能分离出来，放在 BufferQueueCore 这个类中。BufferQueueProducer 和 BufferQueueConsumer 分别是它的生产者和消费者实现基类（分别实现了 IGraphicBufferProducer 和 IGraphicBufferConsumer 接口）。它们都是由 BufferQueue 的静态[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0") createBufferQueue() 来创建的。Surface 是生产者端的实现类，提供 dequeueBuffer/queueBuffer 等硬件渲染接口，和 lockCanvas/unlockCanvasAndPost 等软件渲染接口，使内容流的源可以往 BufferQueue 中填 graphic buffer。GLConsumer 继承自 ConsumerBase，是消费者端的实现类。它在基类的基础上添加了 GL 相关的操作，如将 graphic buffer 中的内容转为 GL 纹理等操作。到此，以 SurfaceTexture 为中心的一个 pipeline 大体是这样的：

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8cb1cee9a9?imageView2/0/w/1280/h/960/ignore-error/1)

TextureView
-----------

在 4.0(API level 14) 中引入。它可以将内容流直接投影到 View 中，可以用于实现 Live preview 等功能。和 SurfaceView 不同，**它不会在 WMS 中单独创建窗口，而是作为 View hierachy 中的一个普通 View**，因此可以和其它普通 View 一样进行移动，旋转，缩放，动画等变化。值得注意的是 **TextureView 必须在硬件加速的窗口中。**它显示的内容流数据可以来自 App 进程或是远端进程。从类图中可以看到，TextureView 继承自 View，它与其它的 View 一样在 View hierachy 中管理与绘制。TextureView 重载了 draw() 方法，其中主要把 SurfaceTexture 中收到的图像数据作为纹理更新到对应的 HardwareLayer 中。SurfaceTexture.OnFrameAvailableListener 用于通知 TextureView 内容流有新图像到来。SurfaceTextureListener 接口用于让 TextureView 的使用者知道 SurfaceTexture 已准备好，这样就可以把 SurfaceTexture 交给相应的内容源。Surface 为 BufferQueue 的 Producer 接口实现类，使生产者可以通过它的软件或硬件渲染接口为 SurfaceTexture 内部的 BufferQueue 提供 graphic buffer。

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c52623819?imageView2/0/w/1280/h/960/ignore-error/1)

下面以 VideoDumpView.[java](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3Djava%26k0%3Djava%26kdi0%3D0%26luki%3D10%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=java&k0=java&kdi0=0&luki=10&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")（位于 / frameworks/[base](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3Dbase%26k0%3Dbase%26kdi0%3D0%26luki%3D1%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=base&k0=base&kdi0=0&luki=1&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")/media/tests/MediaDump/[src](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3Dsrc%26k0%3Dsrc%26kdi0%3D0%26luki%3D4%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=src&k0=src&kdi0=0&luki=4&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")/com/android/mediadump/）为例分析下 SurfaceTexture 的使用。这个例子的效果是从 MediaPlayer 中拿到视频帧，然后显示在屏幕上，接着把屏幕上的内容 dump 到指定文件中。因为 SurfaceTexture 本身只产生纹理，所以这里还需要 GLSurfaceView 配合来做最后的渲染输出。

首先，VideoDumpView 是 GLSurfaceView 的继承类。在构造函数 VideoDumpView() 中会创建 VideoDumpRenderer，也就是 GLSurfaceView.Renderer 的实例，然后调 setRenderer() 将之设成 GLSurfaceView 的 Renderer。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

随后，GLSurfaceView 中的 GLThread 启动，创建 EGL 环境后回调 VideoDumpRenderer 中的 onSurfaceCreated()。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

这里，首先通过 GLES 创建 GL 的外部纹理。外部纹理说明它的真正内容是放在 [ion](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3Dion%26k0%3Dion%26kdi0%3D0%26luki%3D2%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=ion&k0=ion&kdi0=0&luki=2&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0") 分配出来的系统物理[内存](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25C4%25DA%25B4%25E6%26k0%3D%25C4%25DA%25B4%25E6%26kdi0%3D0%26luki%3D6%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%C4%DA%B4%E6&k0=%C4%DA%B4%E6&kdi0=0&luki=6&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")中，而不是 GPU 中，GPU 中只是维护了其元数据。接着根据前面创建的 GL 纹理对象创建 SurfaceTexture。流程如下：

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8cb6af0f70?imageView2/0/w/1280/h/960/ignore-error/1)

SurfaceTexture 的参数为 GLES 接口函数 glGenTexture() 得到的纹理对象 id。在初始化[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0") SurfaceTexture_init() 中，先创建 GLConsumer 和相应的 BufferQueue，再将它们的指针通过 JNI 放到 SurfaceTexture 的 Java 层对象成员中。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

由于直接的 Listener 在 Java 层，而触发者在 Native 层，因此需要从 Native 层回调到 Java 层。这里通过 JNISurfaceTextureContext 当了跳板。JNISurfaceTextureContext 的 onFrameAvailable() 起到了 Native 和 Java 的桥接作用：

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

其中的 fields.postEvent 早在 SurfaceTexture_classInit() 中被初始化为 SurfaceTexture 的 postEventFromNative() 函数。这个函数往所在线程的消息队列中放入消息，异步调用 VideoDumpRenderer 的 onFrameAvailable() 函数，通知 VideoDumpRenderer 有新的数据到来。

回到 onSurfaceCreated()，接下来创建供外部生产者使用的 Surface 类。Surface 的构造[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")之一带有参数 SurfaceTexture。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

它实际上是把 SurfaceTexture 中创建的 BufferQueue 的 Producer 接口实现类拿出来后创建了相应的 Surface 类。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

这样，Surface 为 BufferQueue 的 Producer 端，SurfaceTexture 中的 GLConsumer 为 BufferQueue 的 Consumer 端。当通过 Surface 绘制时，SurfaceTexture 可以通过 updateTexImage() 来将绘制结果绑定到 GL 的纹理中。

回到 onSurfaceCreated() 函数，接下来调用 setOnFrameAvailableListener() 函数将 VideoDumpRenderer（实现 SurfaceTexture.OnFrameAvailableListener 接口）作为 SurfaceTexture 的 Listener，因为它要监听内容流上是否有新数据。接着将 SurfaceTexture 传给 MediaPlayer，因为这里 MediaPlayer 是生产者，SurfaceTexture 是消费者。后者要接收前者输出的 Video frame。这样，就通过 Observer pattern 建立起了一条通知链：MediaPlayer -> SurfaceTexture -> VideDumpRenderer。在 onFrameAvailable() 回调函数中，将 updateSurface 标志设为 true，表示有新的图像到来，需要更新 Surface 了。为毛不在这儿马上更新纹理呢，因为当前可能不在渲染线程。SurfaceTexture 对象可以在任意线程被创建（回调也会在该线程被调用），但 updateTexImage() 只能在含有纹理对象的 GL context 所在线程中被调用。因此一般情况下回调中不能直接调用 updateTexImage()。

与此同时，GLSurfaceView 中的 GLThread 也在运行，它会调用到 VideoDumpRenderer 的绘制[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0") onDrawFrame()。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

这里，通过 SurfaceTexture 的 updateTexImage() 将内容流中的新图像转成 GL 中的纹理，再进行坐标转换。绑定刚生成的纹理，画到屏幕上。整个流程如下：

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8cc84330d5?imageView2/0/w/1280/h/960/ignore-error/1)

最后 onDrawFrame() 调用 DumpToFile() 将屏幕上的内容倒到文件中。在 DumpToFile() 中，先用 glReadPixels() 从屏幕中把像素数据存到 Buffer 中，然后用 FileOutputStream 输出到文件。

上面讲了 SurfaceTexture，下面看看 TextureView 是如何工作的。还是从例子着手，Android 的关于 TextureView 的官方文档 (http://developer.android.com/reference/android/view/TextureView.html) 给了一个简洁的例子 LiveCameraActivity。它它可以将 Camera 中的内容放在 View 中进行显示。在 onCreate()函数中首先创建 TextureView，再将 Activity(实现了 TextureView.SurfaceTextureListener 接口)传给 TextureView，用于监听 SurfaceTexture 准备好的信号。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

TextureView 的构造函数并不做主要的初始化工作。主要的初始化工作是在 getHardwareLayer() 中，而这个[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")是在其基类 View 的 draw() 中调用。TextureView 重载了这个函数：

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

因为 TextureView 是硬件加速层（类型为 LAYER_TYPE_HARDWARE），它首先通过 HardwareRenderer 创建相应的 HardwareLayer 类，放在 mLayer 成员中。然后创建 SurfaceTexture 类，具体流程见前文。之后将 HardwareLayer 与 SurfaceTexture 做绑定。接着调用 Native [函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0") nCreateNativeWindow，它通过 SurfaceTexture 中的 BufferQueueProducer 创建 Surface 类。注意 Surface 实现了 ANativeWindow 接口，这意味着它可以作为 EGL Surface 传给 EGL 接口从而进行硬件绘制。然后 setOnFrameAvailableListener() 将监听者 mUpdateListener 注册到 SurfaceTexture。这样，当内容流上有新的图像到来，mUpdateListener 的 onFrameAvailable() 就会被调用。然后需要调用注册在 TextureView 中的 SurfaceTextureListener 的 onSurfaceTextureAvailable() 回调函数，通知 TextureView 的使用者 SurfaceTexture 已就绪。整个流程大体如下：

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8ceda62604?imageView2/0/w/1280/h/960/ignore-error/1)

注意这里这里为 TextureView 创建了 DeferredLayerUpdater，而不是像 Android 4.4(Kitkat) 中返回 GLES20TextureLayer。因为 Android 5.0(Lollipop) 中在 App 端分离出了渲染线程，并将渲染工作放到该线程中。这个线程还能接收 VSync 信号，因此它还能自己处理动画。事实上，这里 DeferredLayerUpdater 的创建就是通过同步方式在渲染线程中做的。DeferredLayerUpdater，顾名思义，就是将 Layer 的更新请求先记录在这，当渲染线程真正要画的时候，再进行真正的操作。其中的 setSurfaceTexture() 会调用 HardwareLayer 的 Native 函数 nSetSurfaceTexture() 将 SurfaceTexture 中的 surfaceTexture 成员（类型为 GLConsumer）传给 DeferredLayerUpdater，这样之后要更新纹理时 DeferredLayerUpdater 就知道从哪里更新了。

前面提到初始化中会调用 onSurfaceTextureAvailable() 这个回调[函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")。在它的实现中，TextureView 的使用者就可以将准备好的 SurfaceTexture 传给数据源模块，供数据源输出之用。如：

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

看一下 setPreviewTexture() 的实现，其中把 SurfaceTexture 中初始化时创建的 GraphicBufferProducer 拿出来传给 Camera 模块。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

到这里，一切都初始化地差不多了。接下来当内容流有新图像可用，TextureView 会被通知到（通过 SurfaceTexture.OnFrameAvailableListener 接口）。SurfaceTexture.OnFrameAvailableListener 是 SurfaceTexture 有新内容来时的回调接口。TextureView 中的 mUpdateListener 实现了该接口：

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

可以看到其中会调用 updateLayer() 函数，然后通过 invalidate() 函数申请更新 UI。updateLayer() 会设置 mUpdateLayer 标志位。这样，当下次 VSync 到来时，Choreographer 通知 App 通过重绘 View hierachy。在 UI 重绘函数 performTranversals() 中，作为 View hierachy 的一分子，TextureView 的 draw() 函数被调用，其中便会相继调用 applyUpdate() 和 HardwareLayer 的 updateSurfaceTexture() 函数。

[![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8c425ed6ea?imageView2/0/w/1280/h/960/ignore-error/1)](https://link.juejin.cn/?target=undefined)

updateSurfaceTexture() 实际通过 JNI 调用到 android_view_HardwareLayer_updateSurfaceTexture() [函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")。在其中会设置相应 DeferredLayerUpdater 的标志位 mUpdateTexImage，它表示在渲染线程中需要更新该层的纹理。

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8cf8f32b04?imageView2/0/w/1280/h/960/ignore-error/1)

前面提到，**Android 5.0 引入了渲染线程**，它是一个更大的 topic，超出本文范围，这里只说相关的部分。作为背景知识，下面只画出了相关的类。可以看到，ThreadedRenderer 作为新的 HardwareRenderer 替代了 Android 4.4 中的 Gl20Renderer。其中比较关键的是 RenderProxy 类，需要让渲染线程干活时就通过这个类往渲染线程发任务。RenderProxy 中指向的 RenderThread 就是渲染线程的主体了，其中的 threadLoop() 函数是主循环，大多数时间它会 poll 在线程的 Looper 上等待，当有同步请求（或者 VSync 信号）过来，它会被唤醒，然后处理 TaskQueue 中的任务。TaskQueue 是 RenderTask 的队列，RenderTask 代表一个渲染线程中的任务。如 DrawFrameTask 就是 RenderTask 的继承类之一，它主要用于渲染当前帧。而 DrawFrameTask 中的 DeferredLayerUpdater 集合就存放着之前对硬件加速层的更新操作申请。

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8d0dff9f18?imageView2/0/w/1280/h/960/ignore-error/1)

当主线程准备好渲染数据后，会以同步方式让渲染线程完成渲染工作。其中会先调用 processLayerUpdate() 更新所有硬件加速层中的属性，继而调用到 DeferredLayerUpdater 的 apply() [函数](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25BA%25AF%25CA%25FD%26k0%3D%25BA%25AF%25CA%25FD%26kdi0%3D0%26luki%3D8%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%BA%AF%CA%FD&k0=%BA%AF%CA%FD&kdi0=0&luki=8&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")，其中检测到标志位 mUpdateTexImage 被置位，于是会调用 doUpdateTexImage() 真正更新 GL 纹理和转换坐标。

![](https://user-gold-cdn.xitu.io/2019/7/2/16bb0d8d4b496930?imageView2/0/w/1280/h/960/ignore-error/1)

最后，总结下这几者的区别和联系。简单地说:

**SurfaceView 是一个有自己独立 Surface 的 View, 它的渲染可以放在单独线程而不是主线程中, 其缺点是不能做变形和动画。**

**SurfaceTexture 可以用作非直接输出的内容流，这样就提供二次处理的机会。**与 SurfaceView 直接输出相比，这样会有若干帧的延迟。同时，由于它本身管理 BufferQueue，因此[内存](https://link.juejin.cn/?target=http%3A%2F%2Fcpro.baidu.com%2Fcpro%2Fui%2Fuijs.php%3Fapp_id%3D0%26c%3Dnews%26cf%3D1001%26ch%3D0%26di%3D128%26fv%3D18%26is_app%3D0%26jk%3Dddd62cbeae8a0ad1%26k%3D%25C4%25DA%25B4%25E6%26k0%3D%25C4%25DA%25B4%25E6%26kdi0%3D0%26luki%3D6%26n%3D10%26p%3Dbaidu%26q%3D65035100_cpr%26rb%3D0%26rs%3D1%26seller_id%3D1%26sid%3Dd10a8aaebe2cd6dd%26ssp2%3D1%26stid%3D0%26t%3Dtpclicked3_hc%26tu%3Du1836545%26u%3Dhttp%253A%252F%252Fwww%252Ebubuko%252Ecom%252Finfodetail%252D656030%252Ehtml%26urlid%3D0 "http://cpro.baidu.com/cpro/ui/uijs.php?app_id=0&c=news&cf=1001&ch=0&di=128&fv=18&is_app=0&jk=ddd62cbeae8a0ad1&k=%C4%DA%B4%E6&k0=%C4%DA%B4%E6&kdi0=0&luki=6&n=10&p=baidu&q=65035100_cpr&rb=0&rs=1&seller_id=1&sid=d10a8aaebe2cd6dd&ssp2=1&stid=0&t=tpclicked3_hc&tu=u1836545&u=http%3A%2F%2Fwww%2Ebubuko%2Ecom%2Finfodetail%2D656030%2Ehtml&urlid=0")消耗也会稍微大一些。

**TextureView 是一个可以把内容流作为外部纹理输出在上面的 View, 它本身需要是一个硬件加速层。**

事实上 TextureView 本身也包含了 SurfaceTexture, 它与 SurfaceView+SurfaceTexture 组合相比可以完成类似的功能（即把内容流上的图像转成纹理，然后输出）, 区别在于 TextureView 是在 View hierachy 中做绘制，因此一般它是在主线程上做的（在 Android 5.0 引入渲染线程后，它是在渲染线程中做的）。而 SurfaceView+SurfaceTexture 在单独的 Surface 上做绘制，可以是用户提供的线程，而不是系统的主线程或是渲染线程。另外，与 TextureView 相比，它还有个好处是可以用 Hardware overlay 进行显示。