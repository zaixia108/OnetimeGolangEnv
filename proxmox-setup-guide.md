# Proxmox VE Setup Guide for Golang Development Environment

This guide will help you set up Windows virtual machines on Proxmox VE with automated Golang development environment installation.

## Prerequisites

1. Proxmox VE installed and running (version 7.0 or higher recommended)
2. Windows Server 2019/2022 or Windows 10/11 ISO image
3. Sufficient storage space (at least 100GB per VM)
4. Network connectivity for the VMs

## Part 1: Proxmox VE Configuration

### Step 1: Upload Windows ISO

1. Log in to Proxmox VE web interface
2. Navigate to your storage (e.g., `local`)
3. Click on `ISO Images`
4. Click `Upload` and select your Windows ISO file
5. Wait for the upload to complete

### Step 2: Create a VM Template (Recommended)

Creating a template allows you to quickly deploy multiple identical VMs.

#### Option A: Using Proxmox Web Interface

1. Click on `Create VM` button
2. Configure the VM with these recommended settings:

   **General:**
   - VM ID: Choose a unique ID (e.g., 100)
   - Name: `win-golang-template`

   **OS:**
   - ISO image: Select your uploaded Windows ISO
   - Guest OS Type: Microsoft Windows
   - Version: Choose appropriate version (10/2016, 11/2022, etc.)

   **System:**
   - Graphic card: Default
   - Machine: q35
   - BIOS: OVMF (UEFI)
   - Add EFI Disk: Yes (select appropriate storage)
   - SCSI Controller: VirtIO SCSI single

   **Disks:**
   - Bus/Device: SCSI 0
   - Storage: Choose your storage
   - Disk size: 100 GB (minimum)
   - Cache: Write back
   - Discard: Yes (if using thin provisioning)
   - SSD emulation: Yes (if on SSD storage)

   **CPU:**
   - Cores: 4 (minimum, 8 recommended)
   - Type: host (for best performance)

   **Memory:**
   - Memory (MiB): 8192 (8GB minimum, 16GB recommended)
   - Ballooning Device: Yes

   **Network:**
   - Bridge: vmbr0 (or your configured bridge)
   - Model: VirtIO (paravirtualized)
   - Firewall: Optional

3. Click `Finish` but **don't start the VM yet**

#### Option B: Using Proxmox CLI

You can also use the command line to create VMs. SSH into your Proxmox host and run:

```bash
# Create VM
qm create 100 \
  --name win-golang-template \
  --memory 8192 \
  --cores 4 \
  --cpu host \
  --sockets 1 \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single \
  --scsi0 local-lvm:100,cache=writeback,discard=on,ssd=1 \
  --ide2 local:iso/Windows-2022.iso,media=cdrom \
  --boot order=scsi0 \
  --ostype win11 \
  --machine q35 \
  --bios ovmf \
  --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1

# Adjust disk size if needed
qm resize 100 scsi0 100G
```

### Step 3: Install Windows on the VM

1. Start the VM
2. Open the console (noVNC or SPICE)
3. Follow Windows installation wizard
4. Choose appropriate Windows edition
5. Configure initial settings:
   - Language and region
   - Create an administrator account
   - Skip Microsoft account sign-in if possible (use local account)
   - Disable privacy settings as needed

### Step 4: Install VirtIO Drivers (Important!)

For best performance, install VirtIO drivers:

1. Download VirtIO drivers ISO from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/
2. Upload to Proxmox storage
3. Attach ISO to VM as additional CD-ROM drive
4. In Windows, open Device Manager
5. Update drivers for any unknown devices using the VirtIO ISO

Alternatively, you can attach the VirtIO ISO during Windows installation.

### Step 5: Configure Windows for Automation

1. Enable Windows Remote Desktop:
   ```powershell
   Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
   Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
   ```

2. Set execution policy for PowerShell:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Force
   ```

3. Disable Windows Updates (optional, for template):
   ```powershell
   Stop-Service wuauserv
   Set-Service wuauserv -StartupType Disabled
   ```

### Step 6: Download Setup Scripts to VM

1. In the Windows VM, open PowerShell as Administrator
2. Install Git (if not already installed):
   ```powershell
   # Download and install Git
   Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe" -OutFile "C:\GitInstaller.exe"
   Start-Process -FilePath "C:\GitInstaller.exe" -Args "/VERYSILENT /NORESTART" -Wait
   ```

3. Clone this repository:
   ```powershell
   cd C:\
   git clone https://github.com/zaixia108/OnetimeGolangEnv.git
   ```

## Part 2: Automated Environment Setup

### Option 1: Run Setup Script Manually (First Time)

1. In the Windows VM, open PowerShell as Administrator
2. Navigate to the cloned repository:
   ```powershell
   cd C:\OnetimeGolangEnv
   ```

3. Run the setup script:
   ```powershell
   .\setup-golang-env.ps1
   ```

4. Wait for the installation to complete (this may take 30-60 minutes)
5. Restart the VM when prompted

### Option 2: Automated Setup Using Cloud-Init (Advanced)

For fully automated deployment, you can use Proxmox's cloud-init feature:

1. After Windows installation, install cloudbase-init:
   ```powershell
   Invoke-WebRequest -Uri "https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi" -OutFile "C:\CloudbaseInit.msi"
   Start-Process msiexec.exe -Args "/i C:\CloudbaseInit.msi /qn /l*v C:\cloudbase-init-install.log" -Wait
   ```

2. Configure cloudbase-init to run our setup script on first boot

3. Convert VM to template (see below)

### Option 3: Scheduled Task for Auto-Setup

Create a scheduled task that runs the setup script on first boot:

```powershell
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-ExecutionPolicy Bypass -File C:\OnetimeGolangEnv\setup-golang-env.ps1'
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "GolangEnvSetup" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
```

This will run the setup script automatically when the VM starts for the first time.

## Part 3: Create VM Template

After Windows is installed and configured (but BEFORE running the setup script):

### Using Proxmox Web Interface:

1. Shutdown the VM completely
2. Right-click on the VM in the Proxmox tree
3. Select "Convert to template"
4. Confirm the action

### Using Proxmox CLI:

```bash
# Shutdown VM
qm shutdown 100

# Wait for shutdown to complete, then convert to template
qm template 100
```

## Part 4: Deploy VMs from Template

### Using Proxmox Web Interface:

1. Right-click on the template
2. Select "Clone"
3. Configure:
   - VM ID: Choose new unique ID
   - Name: Give it a descriptive name
   - Mode: Select "Full Clone" (recommended)
4. Click "Clone"
5. Start the new VM
6. The setup script will run automatically if you configured Option 3 above

### Using Proxmox CLI:

```bash
# Clone template to new VM
qm clone 100 101 --name "golang-dev-01" --full

# Optionally, resize disk if needed
qm resize 101 scsi0 +50G

# Start the VM
qm start 101
```

### Bulk Deployment Script

Create multiple VMs at once:

```bash
#!/bin/bash
# bulk-deploy.sh

TEMPLATE_ID=100
START_ID=101
COUNT=5
NAME_PREFIX="golang-dev"

for i in $(seq 1 $COUNT); do
    VM_ID=$((START_ID + i - 1))
    VM_NAME="${NAME_PREFIX}-$(printf "%02d" $i)"
    
    echo "Creating VM: $VM_NAME (ID: $VM_ID)"
    qm clone $TEMPLATE_ID $VM_ID --name "$VM_NAME" --full
    
    # Optional: Start VM immediately
    qm start $VM_ID
    
    # Wait a bit before creating next VM
    sleep 5
done

echo "Deployed $COUNT VMs successfully!"
```

## Part 5: Accessing the VMs

### Option 1: Direct RDP Connection

1. Find the VM's IP address:
   - From Proxmox console: Check the network settings
   - From Windows: Run `ipconfig` in PowerShell

2. Connect using Remote Desktop:
   - Windows: Use built-in Remote Desktop Connection (mstsc.exe)
   - Linux: Use Remmina or rdesktop
   - macOS: Use Microsoft Remote Desktop from App Store

   ```bash
   # Example for Linux
   rdesktop -u Administrator -g 1920x1080 <VM_IP_ADDRESS>
   ```

### Option 2: Through Proxmox VNC/SPICE Console

1. In Proxmox web interface, select the VM
2. Click on "Console"
3. Choose between noVNC or SPICE console

### Option 3: Setup VPN Access (Production Recommended)

For remote access from outside your network:

1. Set up a VPN server (OpenVPN, WireGuard) on Proxmox host
2. Connect to VPN from remote location
3. Access VMs via RDP through VPN

## Part 6: Post-Deployment Verification

After deploying a new VM and running the setup script:

1. Remote connect to the VM
2. Check the setup log: `C:\setup-log.txt`
3. Verify environment info: `C:\EnvironmentInfo.txt`
4. Open PowerShell and verify installations:
   ```powershell
   go version
   git --version
   code --version
   cmake --version
   ```

5. Verify vcpkg:
   ```powershell
   cd C:\vcpkg
   .\vcpkg.exe version
   ```

6. Test Go development:
   ```powershell
   cd C:\GoWorkspace\src\test_env
   .\test_env.exe
   ```

## Advanced Configuration

### Resource Allocation Recommendations

Based on workload:

- **Light Development** (single developer, small projects):
  - CPU: 2-4 cores
  - RAM: 4-8 GB
  - Disk: 50-100 GB

- **Medium Development** (single developer, multiple projects):
  - CPU: 4-8 cores
  - RAM: 8-16 GB
  - Disk: 100-200 GB

- **Heavy Development** (team, large projects, builds):
  - CPU: 8-16 cores
  - RAM: 16-32 GB
  - Disk: 200-500 GB

### Network Configuration

#### Static IP Assignment:

1. In Proxmox, configure DHCP reservations based on MAC address
2. Or, configure static IP in Windows:
   ```powershell
   New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.1.100" -PrefixLength 24 -DefaultGateway "192.168.1.1"
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "8.8.8.8","8.8.4.4"
   ```

#### Firewall Rules:

If using Proxmox firewall, allow RDP:

```bash
# Enable firewall for VM
pvesh set /nodes/{node}/qemu/{vmid}/firewall/options --enable 1

# Add RDP rule
pvesh create /nodes/{node}/qemu/{vmid}/firewall/rules \
  --action ACCEPT \
  --dport 3389 \
  --proto tcp \
  --type in \
  --comment "Allow RDP"
```

### Backup Configuration

Set up automatic backups using Proxmox backup:

1. Navigate to Datacenter > Backup
2. Click "Add"
3. Configure backup schedule:
   - Storage: Choose backup storage
   - Schedule: Daily/Weekly as needed
   - Selection mode: Choose "All" or select specific VMs
   - Compression: ZSTD (recommended)
   - Mode: Snapshot (for running VMs)

### Monitoring and Maintenance

1. **Monitor VM Performance:**
   - Use Proxmox built-in graphs
   - Set up alerts for resource usage

2. **Regular Updates:**
   - Keep Windows updated
   - Update Go version periodically
   - Update vcpkg: `git pull` in vcpkg directory

3. **Snapshot Management:**
   - Create snapshots before major changes
   - Clean up old snapshots regularly

## Troubleshooting

### Common Issues

1. **VirtIO drivers not working:**
   - Ensure you've installed the latest VirtIO drivers
   - Check Device Manager for any unknown devices

2. **Slow performance:**
   - Verify CPU type is set to "host"
   - Enable SSD emulation if on SSD storage
   - Check if ballooning is configured correctly

3. **Network connectivity issues:**
   - Verify bridge configuration in Proxmox
   - Check Windows firewall settings
   - Ensure VirtIO network drivers are installed

4. **Setup script fails:**
   - Check C:\setup-log.txt for detailed error messages
   - Verify internet connectivity
   - Ensure PowerShell execution policy is set correctly

5. **RDP connection refused:**
   - Verify Remote Desktop is enabled in Windows
   - Check Windows Firewall rules
   - Verify network connectivity

### Getting Help

- Check the log files: `C:\setup-log.txt`
- Review Proxmox logs: `/var/log/pve/`
- Proxmox documentation: https://pve.proxmox.com/wiki/
- Go documentation: https://golang.org/doc/

## Security Considerations

1. **Use strong passwords** for Windows accounts
2. **Enable Windows Firewall** for public networks
3. **Keep systems updated** with latest security patches
4. **Use VPN** for remote access instead of exposing RDP directly
5. **Regular backups** to prevent data loss
6. **Limit user privileges** - don't use Administrator for daily work
7. **Enable Windows Defender** or other antivirus software

## Customization

You can customize the setup script by modifying parameters:

```powershell
# Custom Golang version and paths
.\setup-golang-env.ps1 -GolangVersion "1.22.0" -VcpkgPath "D:\vcpkg" -WorkspacePath "D:\GoProjects"
```

Or edit the script directly to add/remove components as needed.

## Conclusion

You now have a fully automated Golang development environment on Proxmox VE! You can:

1. Deploy VMs from template in minutes
2. Automatically set up complete development environment
3. Remote connect and start developing immediately
4. Scale horizontally by creating more VMs as needed

For questions or issues, please open an issue on the GitHub repository.
