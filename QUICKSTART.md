# Quick Start Guide | 快速开始指南

[English](#english-quick-start) | [中文](#chinese-quick-start)

---

<a name="chinese-quick-start"></a>
## 中文快速开始

### 5分钟快速部署

#### 前提条件
- ✅ Proxmox VE 已安装
- ✅ Windows ISO 镜像已上传
- ✅ 网络已配置

#### 步骤 1: 创建 Windows 虚拟机 (10分钟)

在 Proxmox VE 网页界面:

1. 点击 **创建虚拟机**
2. 填写基本信息:
   - 名称: `golang-dev-template`
   - ISO: 选择 Windows ISO
3. 系统设置:
   - BIOS: OVMF (UEFI)
   - 添加 EFI 磁盘
4. 硬盘设置:
   - 大小: 100 GB
   - 类型: SCSI
5. CPU: 4 核心
6. 内存: 8192 MB (8GB)
7. 网络: VirtIO
8. 完成并启动虚拟机

#### 步骤 2: 安装 Windows (15-20分钟)

1. 启动虚拟机
2. 打开控制台
3. 按照向导安装 Windows
4. 创建管理员账户
5. 完成初始设置

#### 步骤 3: 在虚拟机中运行自动化脚本 (30-60分钟)

打开 PowerShell (管理员):

```powershell
# 1. 设置执行策略
Set-ExecutionPolicy RemoteSigned -Force

# 2. 安装 Git (如果还没有)
Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile "C:\GitInstaller.exe"
Start-Process -FilePath "C:\GitInstaller.exe" -Args "/VERYSILENT /NORESTART" -Wait

# 3. 克隆仓库
cd C:\
git clone https://github.com/zaixia108/OnetimeGolangEnv.git

# 4. 运行安装脚本
cd C:\OnetimeGolangEnv
.\setup-golang-env.ps1

# 等待完成后重启
Restart-Computer
```

#### 步骤 4: 开始开发！

重启后:
1. 使用远程桌面连接到虚拟机
2. 打开 Visual Studio Code
3. 创建你的第一个 Go 项目:

```powershell
cd C:\GoWorkspace\src
mkdir hello
cd hello
go mod init hello
code .
```

创建 `main.go`:
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Golang!")
}
```

运行:
```powershell
go run main.go
```

### 批量部署（可选）

如果需要创建多个相同的环境:

#### 1. 先创建模板

在第一个虚拟机配置完成后:
```bash
# 在 Proxmox 主机上执行
qm shutdown 100
qm template 100
```

#### 2. 批量克隆

```bash
# 克隆 5 个虚拟机
cd /path/to/OnetimeGolangEnv
chmod +x examples/bulk-deploy.sh
./examples/bulk-deploy.sh -c 5
```

### 验证安装

```powershell
# 检查 Golang
go version

# 检查 Git
git --version

# 检查 vcpkg
cd C:\vcpkg
.\vcpkg.exe version

# 查看日志
type C:\setup-log.txt
type C:\EnvironmentInfo.txt
```

### 常见问题

**Q: 安装失败怎么办？**
A: 查看 `C:\setup-log.txt` 获取详细错误信息

**Q: 如何更改 Golang 版本？**
A: 运行 `.\setup-golang-env.ps1 -GolangVersion "1.22.0"`

**Q: 如何连接到虚拟机？**
A: 使用 Windows 远程桌面，输入虚拟机的 IP 地址

**Q: 如何查看虚拟机 IP？**
A: 在虚拟机中运行 `ipconfig` 或在 Proxmox 中查看

---

<a name="english-quick-start"></a>
## English Quick Start

### 5-Minute Quick Deploy

#### Prerequisites
- ✅ Proxmox VE installed
- ✅ Windows ISO uploaded
- ✅ Network configured

#### Step 1: Create Windows VM (10 minutes)

In Proxmox VE web interface:

1. Click **Create VM**
2. Fill basic info:
   - Name: `golang-dev-template`
   - ISO: Select Windows ISO
3. System settings:
   - BIOS: OVMF (UEFI)
   - Add EFI Disk
4. Disk settings:
   - Size: 100 GB
   - Type: SCSI
5. CPU: 4 cores
6. Memory: 8192 MB (8GB)
7. Network: VirtIO
8. Finish and start VM

#### Step 2: Install Windows (15-20 minutes)

1. Start the VM
2. Open console
3. Follow Windows installation wizard
4. Create administrator account
5. Complete initial setup

#### Step 3: Run Automation Script in VM (30-60 minutes)

Open PowerShell (Administrator):

```powershell
# 1. Set execution policy
Set-ExecutionPolicy RemoteSigned -Force

# 2. Install Git (if not already installed)
Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile "C:\GitInstaller.exe"
Start-Process -FilePath "C:\GitInstaller.exe" -Args "/VERYSILENT /NORESTART" -Wait

# 3. Clone repository
cd C:\
git clone https://github.com/zaixia108/OnetimeGolangEnv.git

# 4. Run setup script
cd C:\OnetimeGolangEnv
.\setup-golang-env.ps1

# Restart after completion
Restart-Computer
```

#### Step 4: Start Developing!

After restart:
1. Connect via Remote Desktop
2. Open Visual Studio Code
3. Create your first Go project:

```powershell
cd C:\GoWorkspace\src
mkdir hello
cd hello
go mod init hello
code .
```

Create `main.go`:
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Golang!")
}
```

Run:
```powershell
go run main.go
```

### Bulk Deployment (Optional)

To create multiple identical environments:

#### 1. Create Template First

After first VM is configured:
```bash
# On Proxmox host
qm shutdown 100
qm template 100
```

#### 2. Bulk Clone

```bash
# Clone 5 VMs
cd /path/to/OnetimeGolangEnv
chmod +x examples/bulk-deploy.sh
./examples/bulk-deploy.sh -c 5
```

### Verify Installation

```powershell
# Check Golang
go version

# Check Git
git --version

# Check vcpkg
cd C:\vcpkg
.\vcpkg.exe version

# View logs
type C:\setup-log.txt
type C:\EnvironmentInfo.txt
```

### FAQ

**Q: What if installation fails?**
A: Check `C:\setup-log.txt` for detailed error information

**Q: How to change Golang version?**
A: Run `.\setup-golang-env.ps1 -GolangVersion "1.22.0"`

**Q: How to connect to VM?**
A: Use Windows Remote Desktop with VM's IP address

**Q: How to find VM IP?**
A: Run `ipconfig` in VM or check in Proxmox interface

---

## Support

- 📖 [Full Documentation](README.md)
- 🔧 [Proxmox Setup Guide](proxmox-setup-guide.md)
- 💬 [Issues](https://github.com/zaixia108/OnetimeGolangEnv/issues)

## Tips

💡 **Pro Tips:**
- Use SSD storage for better performance
- Create snapshots before major changes
- Set up VPN for secure remote access
- Regular backups save time and data
- Monitor resource usage to optimize allocation

🎯 **Optimization:**
- Increase CPU cores for faster builds
- More RAM for multiple projects
- Larger disk for extensive libraries
- Use template for quick scaling
