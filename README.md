# OnetimeGolangEnv

一键式自动化 Golang 开发环境部署方案 | One-Time Golang Development Environment Setup

[English](#english) | [中文](#chinese)

---

<a name="chinese"></a>
## 中文说明

### 概述

这是一个完整的自动化解决方案，用于在 Proxmox VE 虚拟化平台上快速部署 Windows 虚拟机，并自动安装配置完整的 Golang 开发环境。

### 核心功能

✅ **完全自动化安装**
- Golang 最新版本
- Git 版本控制
- Visual Studio Build Tools (MSBuildTools)
- vcpkg C++ 包管理器
- Visual Studio Code 及常用扩展
- CMake 和 Ninja 构建工具

✅ **一键式部署**
- 使用 PowerShell 脚本自动完成所有配置
- 创建虚拟机后自动运行设置
- 无需人工干预

✅ **即插即用**
- 远程桌面自动启用
- 开发环境预配置
- 完成后即可开始开发

### 快速开始

#### 1. 准备工作

- Proxmox VE 7.0+ 虚拟化平台
- Windows Server 2019/2022 或 Windows 10/11 ISO 镜像
- 至少 100GB 存储空间（每个虚拟机）
- 网络连接

#### 2. 在 Proxmox VE 上创建虚拟机

推荐配置：
- **CPU**: 4-8 核心
- **内存**: 8-16 GB
- **硬盘**: 100 GB (SSD 推荐)
- **网络**: VirtIO 网卡

详细步骤请参考: [Proxmox 设置指南](proxmox-setup-guide.md)

#### 3. 在 Windows 虚拟机中运行自动化脚本

1. 下载或克隆本仓库到虚拟机：
```powershell
cd C:\
git clone https://github.com/zaixia108/OnetimeGolangEnv.git
```

2. 以管理员身份运行 PowerShell，执行安装脚本：
```powershell
cd C:\OnetimeGolangEnv
.\setup-golang-env.ps1
```

3. 等待安装完成（约 30-60 分钟），然后重启系统

4. 通过远程桌面连接到虚拟机，开始开发！

### 安装的组件

| 组件 | 说明 |
|------|------|
| **Golang** | Go 编程语言环境 (默认 1.21.5) |
| **Git** | 版本控制系统 |
| **Visual Studio Build Tools** | Microsoft C++ 编译器和构建工具 |
| **vcpkg** | C/C++ 包管理器，默认安装到 `C:\vcpkg` |
| **Visual Studio Code** | 轻量级代码编辑器 |
| **Go 扩展** | 包括 gopls, delve, staticcheck 等 |
| **CMake & Ninja** | 跨平台构建工具 |

### 环境变量配置

安装完成后，以下环境变量将自动配置：

- `GOPATH`: `C:\GoWorkspace`
- `VCPKG_ROOT`: `C:\vcpkg`
- `PATH`: 包含 Go、Git、CMake 等工具路径

### 自定义配置

您可以通过参数自定义安装：

```powershell
.\setup-golang-env.ps1 -GolangVersion "1.22.0" -VcpkgPath "D:\vcpkg" -WorkspacePath "D:\GoProjects"
```

### 文件结构

```
OnetimeGolangEnv/
├── README.md                    # 本文档
├── setup-golang-env.ps1         # 主自动化安装脚本
├── proxmox-setup-guide.md       # Proxmox VE 详细设置指南
└── examples/                    # 示例配置和脚本
    ├── bulk-deploy.sh          # 批量部署虚拟机脚本
    └── vm-config.json          # 虚拟机配置模板
```

### 验证安装

安装完成后，可以通过以下命令验证：

```powershell
# 检查 Go 版本
go version

# 检查 Git
git --version

# 检查 vcpkg
cd C:\vcpkg
.\vcpkg.exe version

# 运行测试程序
cd C:\GoWorkspace\src\test_env
.\test_env.exe
```

### 日志和故障排除

- 安装日志: `C:\setup-log.txt`
- 环境信息: `C:\EnvironmentInfo.txt`

如遇问题，请查看日志文件获取详细错误信息。

### 高级用法

#### 批量部署多个虚拟机

```bash
# 在 Proxmox 主机上运行
./examples/bulk-deploy.sh
```

#### 创建虚拟机模板

1. 安装并配置好 Windows 系统
2. 配置自动运行脚本
3. 在 Proxmox 中将虚拟机转换为模板
4. 从模板克隆新虚拟机

详细步骤参考 [Proxmox 设置指南](proxmox-setup-guide.md)。

### 安全建议

- 使用强密码
- 启用 Windows 防火墙
- 定期更新系统和软件
- 使用 VPN 进行远程访问
- 定期备份虚拟机

### 贡献

欢迎提交 Issue 和 Pull Request！

### 许可证

MIT License

---

<a name="english"></a>
## English Documentation

### Overview

A complete automated solution for quickly deploying Windows virtual machines on Proxmox VE with a fully configured Golang development environment.

### Core Features

✅ **Fully Automated Installation**
- Latest Golang version
- Git version control
- Visual Studio Build Tools (MSBuildTools)
- vcpkg C++ package manager
- Visual Studio Code with common extensions
- CMake and Ninja build tools

✅ **One-Click Deployment**
- PowerShell script handles all configuration
- Automatic setup after VM creation
- No manual intervention required

✅ **Plug and Play**
- Remote Desktop automatically enabled
- Pre-configured development environment
- Ready to code immediately

### Quick Start

#### 1. Prerequisites

- Proxmox VE 7.0+ virtualization platform
- Windows Server 2019/2022 or Windows 10/11 ISO image
- At least 100GB storage per VM
- Network connectivity

#### 2. Create VM on Proxmox VE

Recommended configuration:
- **CPU**: 4-8 cores
- **Memory**: 8-16 GB
- **Disk**: 100 GB (SSD recommended)
- **Network**: VirtIO NIC

Detailed steps: [Proxmox Setup Guide](proxmox-setup-guide.md)

#### 3. Run Automation Script in Windows VM

1. Clone this repository to your VM:
```powershell
cd C:\
git clone https://github.com/zaixia108/OnetimeGolangEnv.git
```

2. Run PowerShell as Administrator and execute the setup script:
```powershell
cd C:\OnetimeGolangEnv
.\setup-golang-env.ps1
```

3. Wait for installation to complete (approximately 30-60 minutes), then restart

4. Connect via Remote Desktop and start developing!

### Installed Components

| Component | Description |
|-----------|-------------|
| **Golang** | Go programming language environment (default 1.21.5) |
| **Git** | Version control system |
| **Visual Studio Build Tools** | Microsoft C++ compiler and build tools |
| **vcpkg** | C/C++ package manager, installed at `C:\vcpkg` |
| **Visual Studio Code** | Lightweight code editor |
| **Go Extensions** | Including gopls, delve, staticcheck, etc. |
| **CMake & Ninja** | Cross-platform build tools |

### Environment Variables

After installation, the following environment variables are automatically configured:

- `GOPATH`: `C:\GoWorkspace`
- `VCPKG_ROOT`: `C:\vcpkg`
- `PATH`: Includes Go, Git, CMake, and other tools

### Customization

You can customize the installation with parameters:

```powershell
.\setup-golang-env.ps1 -GolangVersion "1.22.0" -VcpkgPath "D:\vcpkg" -WorkspacePath "D:\GoProjects"
```

### File Structure

```
OnetimeGolangEnv/
├── README.md                    # This document
├── setup-golang-env.ps1         # Main automation setup script
├── proxmox-setup-guide.md       # Detailed Proxmox VE setup guide
└── examples/                    # Example configurations and scripts
    ├── bulk-deploy.sh          # Bulk VM deployment script
    └── vm-config.json          # VM configuration template
```

### Verify Installation

After installation, verify with these commands:

```powershell
# Check Go version
go version

# Check Git
git --version

# Check vcpkg
cd C:\vcpkg
.\vcpkg.exe version

# Run test program
cd C:\GoWorkspace\src\test_env
.\test_env.exe
```

### Logs and Troubleshooting

- Installation log: `C:\setup-log.txt`
- Environment info: `C:\EnvironmentInfo.txt`

Check log files for detailed error information if issues occur.

### Advanced Usage

#### Bulk Deploy Multiple VMs

```bash
# Run on Proxmox host
./examples/bulk-deploy.sh
```

#### Create VM Template

1. Install and configure Windows
2. Configure auto-run script
3. Convert VM to template in Proxmox
4. Clone new VMs from template

Detailed steps in [Proxmox Setup Guide](proxmox-setup-guide.md).

### Security Recommendations

- Use strong passwords
- Enable Windows Firewall
- Keep systems and software updated
- Use VPN for remote access
- Regular VM backups

### Contributing

Issues and Pull Requests are welcome!

### License

MIT License