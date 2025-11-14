# Troubleshooting Guide | 故障排除指南

[English](#english) | [中文](#chinese)

---

<a name="english"></a>
## English

### Common Issues and Solutions

#### 1. Installation Issues

##### Problem: PowerShell Script Fails to Run
```
Error: File cannot be loaded because running scripts is disabled
```

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy RemoteSigned -Force
```

##### Problem: Chocolatey Installation Fails
```
Error: Unable to download Chocolatey installation script
```

**Solutions:**
1. Check internet connectivity:
   ```powershell
   Test-NetConnection google.com
   ```
2. Disable proxy temporarily if enabled
3. Check Windows Firewall settings
4. Try manual Chocolatey installation:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

##### Problem: Go Installation Fails
```
Error: The specified version of Golang could not be found
```

**Solutions:**
1. Check available versions:
   ```powershell
   choco search golang --all-versions
   ```
2. Try without version specification:
   ```powershell
   choco install golang -y
   ```
3. Or specify a different version:
   ```powershell
   .\setup-golang-env.ps1 -GolangVersion "1.22.0"
   ```

##### Problem: vcpkg Clone/Build Fails
```
Error: Failed to clone vcpkg repository
```

**Solutions:**
1. Check Git installation:
   ```powershell
   git --version
   ```
2. Verify GitHub connectivity:
   ```powershell
   Test-NetConnection github.com -Port 443
   ```
3. Try with different path:
   ```powershell
   .\setup-golang-env.ps1 -VcpkgPath "D:\vcpkg"
   ```
4. Clone manually:
   ```powershell
   cd C:\
   git clone https://github.com/microsoft/vcpkg.git
   cd vcpkg
   .\bootstrap-vcpkg.bat
   ```

#### 2. Virtual Machine Issues

##### Problem: VM Performance is Slow

**Solutions:**
1. Check CPU type in Proxmox:
   ```bash
   qm config <vmid> | grep cpu
   ```
   Should show `cpu: host`

2. Enable SSD emulation:
   ```bash
   qm set <vmid> --scsi0 local-lvm:vm-<vmid>-disk-0,ssd=1
   ```

3. Increase resources:
   ```bash
   qm set <vmid> --cores 8
   qm set <vmid> --memory 16384
   ```

4. Check VirtIO drivers are installed in Windows

##### Problem: Network Not Working in VM

**Solutions:**
1. Install VirtIO network drivers:
   - Download virtio-win ISO
   - Attach to VM
   - Install drivers from Device Manager

2. Check bridge configuration:
   ```bash
   ip addr show vmbr0
   ```

3. Verify VM network settings:
   ```bash
   qm config <vmid> | grep net
   ```

4. In Windows, check network adapter:
   ```powershell
   Get-NetAdapter
   ipconfig /all
   ```

##### Problem: Can't Connect via Remote Desktop

**Solutions:**
1. Verify RDP is enabled:
   ```powershell
   Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections"
   ```
   Should be 0

2. Check Windows Firewall:
   ```powershell
   Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Enable-NetFirewallRule
   ```

3. Verify VM is accessible:
   ```powershell
   # From another machine
   Test-NetConnection <VM_IP> -Port 3389
   ```

4. Check VM IP address:
   ```powershell
   ipconfig
   ```

#### 3. Development Environment Issues

##### Problem: Go Commands Not Found After Installation

**Solution:**
```powershell
# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Or restart PowerShell/system
```

##### Problem: GOPATH Not Set Correctly

**Solution:**
```powershell
# Check current GOPATH
go env GOPATH

# Set manually if needed
[System.Environment]::SetEnvironmentVariable("GOPATH", "C:\GoWorkspace", [System.EnvironmentVariableTarget]::Machine)
```

##### Problem: vcpkg Not Working

**Solutions:**
1. Check environment variable:
   ```powershell
   $env:VCPKG_ROOT
   ```

2. Verify vcpkg executable:
   ```powershell
   cd C:\vcpkg
   .\vcpkg.exe version
   ```

3. Re-integrate with Visual Studio:
   ```powershell
   .\vcpkg.exe integrate install
   ```

##### Problem: Visual Studio Build Tools Not Found

**Solutions:**
1. Check installation:
   ```powershell
   & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -all
   ```

2. Reinstall if needed:
   ```powershell
   choco install visualstudio2022buildtools -y --force
   choco install visualstudio2022-workload-vctools -y --force
   ```

#### 4. Proxmox Issues

##### Problem: Can't Create VM Template

**Solution:**
```bash
# Ensure VM is stopped
qm stop <vmid>

# Wait for complete shutdown
qm status <vmid>

# Convert to template
qm template <vmid>
```

##### Problem: Clone Fails with Disk Error

**Solutions:**
1. Check available storage:
   ```bash
   pvesm status
   ```

2. Use different storage:
   ```bash
   qm clone <template-id> <new-vmid> --name newvm --full --storage local-lvm
   ```

3. Check storage permissions:
   ```bash
   ls -la /var/lib/vz/
   ```

##### Problem: VM Won't Start After Clone

**Solutions:**
1. Check VM configuration:
   ```bash
   qm config <vmid>
   ```

2. Remove and re-add network device:
   ```bash
   qm set <vmid> --delete net0
   qm set <vmid> --net0 virtio,bridge=vmbr0
   ```

3. Check logs:
   ```bash
   tail -f /var/log/pve/tasks/active
   ```

### Diagnostic Commands

#### Windows VM Diagnostics

```powershell
# System Information
systeminfo

# Check installed programs
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion

# Check environment variables
Get-ChildItem Env:

# Network diagnostics
ipconfig /all
Test-NetConnection google.com
Get-NetAdapter

# Disk space
Get-PSDrive C

# Check Windows services
Get-Service | Where-Object {$_.DisplayName -like "*Remote*"}

# PowerShell version
$PSVersionTable
```

#### Proxmox Host Diagnostics

```bash
# Check PVE version
pveversion

# VM status
qm status <vmid>

# VM configuration
qm config <vmid>

# Storage status
pvesm status

# Network configuration
ip addr show
brctl show

# System resources
top
free -h
df -h

# VM logs
tail -100 /var/log/pve/tasks/active
```

### Log Files

#### Windows
- Setup log: `C:\setup-log.txt`
- Environment info: `C:\EnvironmentInfo.txt`
- Windows Event Viewer: `eventvwr.msc`
- PowerShell transcript: Check script for path

#### Proxmox
- Task logs: `/var/log/pve/tasks/`
- System log: `/var/log/syslog`
- VM log: `/var/log/pve/qemu-server/`

### Getting Help

If you can't resolve the issue:

1. Check the logs for detailed error messages
2. Search existing issues: https://github.com/zaixia108/OnetimeGolangEnv/issues
3. Create a new issue with:
   - Detailed description of the problem
   - Steps to reproduce
   - Error messages from logs
   - System configuration details
   - What you've already tried

---

<a name="chinese"></a>
## 中文

### 常见问题及解决方案

#### 1. 安装问题

##### 问题：PowerShell 脚本无法运行
```
错误：无法加载文件，因为在此系统上禁止运行脚本
```

**解决方案：**
```powershell
# 以管理员身份运行
Set-ExecutionPolicy RemoteSigned -Force
```

##### 问题：Chocolatey 安装失败
```
错误：无法下载 Chocolatey 安装脚本
```

**解决方案：**
1. 检查网络连接：
   ```powershell
   Test-NetConnection google.com
   ```
2. 暂时禁用代理（如果启用）
3. 检查 Windows 防火墙设置
4. 尝试手动安装 Chocolatey

##### 问题：Go 安装失败

**解决方案：**
1. 查看可用版本：
   ```powershell
   choco search golang --all-versions
   ```
2. 指定不同版本：
   ```powershell
   .\setup-golang-env.ps1 -GolangVersion "1.22.0"
   ```

##### 问题：vcpkg 克隆/构建失败

**解决方案：**
1. 检查 Git 安装：
   ```powershell
   git --version
   ```
2. 手动克隆：
   ```powershell
   cd C:\
   git clone https://github.com/microsoft/vcpkg.git
   cd vcpkg
   .\bootstrap-vcpkg.bat
   ```

#### 2. 虚拟机问题

##### 问题：虚拟机性能慢

**解决方案：**
1. 检查 CPU 类型（应该是 `host`）
2. 启用 SSD 仿真
3. 增加资源分配
4. 安装 VirtIO 驱动

##### 问题：网络不工作

**解决方案：**
1. 安装 VirtIO 网络驱动
2. 检查桥接配置
3. 检查 Windows 防火墙
4. 检查网络适配器

##### 问题：无法通过远程桌面连接

**解决方案：**
1. 验证 RDP 已启用
2. 检查防火墙规则
3. 验证 IP 地址正确
4. 测试端口 3389 是否可访问

#### 3. 开发环境问题

##### 问题：安装后找不到 Go 命令

**解决方案：**
```powershell
# 刷新环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 或重启 PowerShell/系统
```

##### 问题：GOPATH 未正确设置

**解决方案：**
```powershell
# 检查 GOPATH
go env GOPATH

# 手动设置
[System.Environment]::SetEnvironmentVariable("GOPATH", "C:\GoWorkspace", [System.EnvironmentVariableTarget]::Machine)
```

##### 问题：vcpkg 不工作

**解决方案：**
1. 检查环境变量
2. 验证 vcpkg 可执行文件
3. 重新集成 Visual Studio

#### 4. Proxmox 问题

##### 问题：无法创建虚拟机模板

**解决方案：**
```bash
# 确保虚拟机已停止
qm stop <vmid>
qm template <vmid>
```

##### 问题：克隆失败

**解决方案：**
1. 检查可用存储空间
2. 使用不同的存储
3. 检查存储权限

### 诊断命令

#### Windows 诊断
```powershell
systeminfo
ipconfig /all
Get-NetAdapter
Get-PSDrive C
```

#### Proxmox 诊断
```bash
pveversion
qm status <vmid>
pvesm status
df -h
```

### 日志文件

#### Windows
- 安装日志：`C:\setup-log.txt`
- 环境信息：`C:\EnvironmentInfo.txt`

#### Proxmox
- 任务日志：`/var/log/pve/tasks/`
- 系统日志：`/var/log/syslog`

### 获取帮助

如果无法解决问题：

1. 查看日志获取详细错误信息
2. 搜索现有问题
3. 创建新的 issue 并提供：
   - 问题详细描述
   - 复现步骤
   - 错误日志
   - 系统配置信息
