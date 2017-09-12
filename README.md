# GitHubReader
用浏览器浏览github的时候，想看一下开源项目的代码质量如何然后才决定是否star，通常是打开多个标签页来浏览，我觉得这样做好麻烦，所以才有了这个小项目的初衷。原理很简单，就是把想要浏览的项目通过简单的正则筛选出文件信息，组成html文件，然后存储到临时文件夹中，关闭软件的时候再清空临时文件夹。目前一个主要问题就是正则写的不好，效率比较低，导致一些比较大的项目需要很长时间才能处理完成。


![](http://ord6anrvd.bkt.clouddn.com/201709122226_504.png)
![](http://ord6anrvd.bkt.clouddn.com/201709122232_612.png)
![](http://ord6anrvd.bkt.clouddn.com/201709122232_263.png)
![](http://ord6anrvd.bkt.clouddn.com/201709122234_264.png)
# Dependencies
- Qt >= 5.9.0
-  QtCreator + MSVC2015
# License
GNU GENERAL PUBLIC LICENSE Version 2
