## Docker
MySQL，Nginx，Redis，Hyperf的Dockerfile和compose。
挂载卷路径都是在本地电脑安装WSL里的。
### window的WSL使用Docker
> 首先电脑上要有WSL，网上有相关文章（搜索词：windows安装WSL2）
>
> 然后在Microsoft Store安装Ubuntu或者Debian等，看自己兴趣
>
> 安装好Linux操作系统后查看[Install on Linux](https://docs.docker.com/desktop/install/linux-install/)官方Docker文档安装

运行安装好的子系统：

```bash
root@0105c:/$ ls
bin   dev  home  lib    lib64   lost+found  mnt  proc  run   snap  sys  usr
boot  etc  init  lib32  libx32  media       opt  root  sbin  srv   tmp  var
root@0105c:/$ cd mnt/
root@0105c:/mnt$ ls
c  d  e  wsl  wslg
root@0105c:/mnt$
```
子系统的 /mnt 目录下有 c、d、e等目录就是对应电脑的C盘、D盘、E盘
但是Docker的挂载卷不能直接访问 /mnt 下的目录，所以可以使用软连接```ln -s [dir1] [dir2]```把 /mnt 目录快捷方式到 /home 等系统目录。就可以挂载到 /home 目录等于挂载了 /mnt 目录。