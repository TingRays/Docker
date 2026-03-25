**WSL 安装的子系统迁移到D盘**
- 导出子系统到 tar 文件
```bash
wsl --export Ubuntu D:\wsl\ubuntu.tar
```
- 注销原子系统
```bash
wsl --unregister Ubuntu
```
- 导入子系统到 D:\wsl\Ubuntu 目录
```bash
wsl --import Ubuntu D:\wsl\Ubuntu D:\wsl\ubuntu.tar --version 2
```

**WSL 无法联网（科学上网）问题**
- 找到 Windows IP，在WSL子系统里面输入命令：
```bash
ip route | grep default
```
- 得到IP（Windows 在 WSL 里的真实 IP）
```bash
default via 172.26.240.1 dev eth0 proto kernel
```
- 配置代理（代理服务器的地址：172.26.240.1和端口：10808）
```bash
export http_proxy="http://172.26.240.1:10808"
export https_proxy="http://172.26.240.1:10808"
export all_proxy="socks5://172.26.240.1:10808"
```
- 测试
```bash
curl google.com -I
```

**代理持久化**
- 编辑 ~/.bashrc 文件
```bash
sudo nano ~/.bashrc
```
- 在文件末尾添加代理配置
```bash
# ===== WSL Proxy =====
WIN_IP=$(ip route | awk '/default/ {print $3}')
export http_proxy="http://$WIN_IP:10808"
export https_proxy="http://$WIN_IP:10808"
export all_proxy="socks5://$WIN_IP:10808"
# =====================
```
- 保存文件并退出
- 使配置生效
```bash
source ~/.bashrc
```