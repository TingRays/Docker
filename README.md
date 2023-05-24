## Docker

MySQL，Nginx，Redis，Hyperf 的 Dockerfile 和 compose。
挂载卷路径都是在本地电脑安装 WSL 里的。

### window 的 WSL 使用 Docker

> 首先电脑上要有 WSL，网上有相关文章（搜索词：windows 安装 WSL2）
>
> 然后在 Microsoft Store 安装 Ubuntu 或者 Debian 等，看自己兴趣
>
> 安装好 Linux 操作系统后查看[Install on Linux](https://docs.docker.com/desktop/install/linux-install/)官方 Docker 文档安装

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

子系统的 /mnt 目录下有 c、d、e 等目录就是对应电脑的 C 盘、D 盘、E 盘
但是 Docker 的挂载卷不能直接访问 /mnt 下的目录（权限组的问题，但修改权限组不生效），所以可以使用软连接`ln -s [dir1] [dir2]`把 /mnt 目录快捷方式到 /home 等系统目录。就可以挂载到 /home 目录等于挂载到了 /mnt 目录。

#### 关于目录挂载

我看到了关于使用软连接`ln -s [dir1] [dir2]`之外的方案：（没有测试过，自己试试）

在 Windows 命令行 （） 中，您可以像这样挂载当前目录：cmd

```bash
docker run --rm -it -v %cd%:/usr/src/project gcc:4.9
```

在 PowerShell 中，使用 ，它为您提供当前目录：${PWD}

```bash
docker run --rm -it -v ${PWD}:/usr/src/project gcc:4.9
```

在 Linux 上：

```bash
docker run --rm -it -v $(pwd):/usr/src/project gcc:4.9
```

**跨平台**
以下选项适用于 PowerShell 和 Linux（至少是 Ubuntu）：

```bash
docker run --rm -it -v ${PWD}:/usr/src/project gcc:4.9
docker run --rm -it -v $(pwd):/usr/src/project gcc:4.9
```
