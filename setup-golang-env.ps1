#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Automated setup script for Golang development environment on Windows
.DESCRIPTION
    This script automatically installs and configures:
    - Golang
    - Git
    - Visual Studio Build Tools (MSBuildTools)
    - vcpkg
    - Visual Studio Code
    And sets up the complete development environment
.NOTES
    Run this script with Administrator privileges
#>

param(
    [string]$GolangVersion = "1.21.5",
    [string]$VcpkgPath = "C:\vcpkg",
    [string]$WorkspacePath = "C:\GoWorkspace"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path "C:\setup-log.txt" -Value $logMessage
}

# Function to download files
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    Write-Log "Downloading from $Url to $OutputPath"
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-Log "Download completed successfully"
        return $true
    }
    catch {
        Write-Log "Download failed: $_" "ERROR"
        return $false
    }
}

# Function to check if a program is installed
function Test-ProgramInstalled {
    param([string]$ProgramName)
    $installed = Get-Command $ProgramName -ErrorAction SilentlyContinue
    return $null -ne $installed
}

Write-Log "=== Starting Golang Development Environment Setup ==="
Write-Log "Golang Version: $GolangVersion"
Write-Log "vcpkg Path: $VcpkgPath"
Write-Log "Workspace Path: $WorkspacePath"

# Create temp directory for downloads
$tempDir = "C:\temp_setup"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    Write-Log "Created temp directory: $tempDir"
}

# 1. Install Chocolatey (package manager for Windows)
Write-Log "=== Step 1: Installing Chocolatey ==="
if (-not (Test-ProgramInstalled "choco")) {
    Write-Log "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Log "Chocolatey installed successfully"
} else {
    Write-Log "Chocolatey already installed"
}

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 2. Install Git
Write-Log "=== Step 2: Installing Git ==="
if (-not (Test-ProgramInstalled "git")) {
    Write-Log "Installing Git..."
    choco install git -y
    Write-Log "Git installed successfully"
} else {
    Write-Log "Git already installed"
}

# 3. Install Golang
Write-Log "=== Step 3: Installing Golang ==="
if (-not (Test-ProgramInstalled "go")) {
    Write-Log "Installing Golang version $GolangVersion..."
    choco install golang --version=$GolangVersion -y
    Write-Log "Golang installed successfully"
} else {
    Write-Log "Golang already installed"
}

# 4. Install Visual Studio Build Tools (MSBuildTools)
Write-Log "=== Step 4: Installing Visual Studio Build Tools ==="
$vswherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswherePath)) {
    Write-Log "Installing Visual Studio Build Tools 2022..."
    choco install visualstudio2022buildtools -y
    choco install visualstudio2022-workload-vctools -y
    Write-Log "Visual Studio Build Tools installed successfully"
} else {
    Write-Log "Visual Studio Build Tools already installed"
}

# 5. Install vcpkg
Write-Log "=== Step 5: Installing vcpkg ==="
if (-not (Test-Path $VcpkgPath)) {
    Write-Log "Cloning vcpkg repository to $VcpkgPath..."
    git clone https://github.com/microsoft/vcpkg.git $VcpkgPath
    
    Write-Log "Bootstrapping vcpkg..."
    Push-Location $VcpkgPath
    .\bootstrap-vcpkg.bat
    Pop-Location
    
    # Set vcpkg environment variable
    [System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", $VcpkgPath, [System.EnvironmentVariableTarget]::Machine)
    Write-Log "vcpkg installed and configured successfully"
    
    # Integrate vcpkg with Visual Studio
    Write-Log "Integrating vcpkg with Visual Studio..."
    & "$VcpkgPath\vcpkg.exe" integrate install
} else {
    Write-Log "vcpkg already installed at $VcpkgPath"
}

# 6. Install Visual Studio Code
Write-Log "=== Step 6: Installing Visual Studio Code ==="
if (-not (Test-Path "${env:ProgramFiles}\Microsoft VS Code\Code.exe")) {
    Write-Log "Installing Visual Studio Code..."
    choco install vscode -y
    Write-Log "Visual Studio Code installed successfully"
} else {
    Write-Log "Visual Studio Code already installed"
}

# 7. Install useful VSCode extensions
Write-Log "=== Step 7: Installing VSCode Extensions ==="
$extensions = @(
    "golang.go",
    "ms-vscode.cpptools",
    "ms-vscode.cmake-tools"
)
foreach ($ext in $extensions) {
    Write-Log "Installing VSCode extension: $ext"
    & code --install-extension $ext --force
}

# 8. Setup Golang workspace
Write-Log "=== Step 8: Setting up Golang Workspace ==="
if (-not (Test-Path $WorkspacePath)) {
    New-Item -ItemType Directory -Path $WorkspacePath | Out-Null
    New-Item -ItemType Directory -Path "$WorkspacePath\src" | Out-Null
    New-Item -ItemType Directory -Path "$WorkspacePath\bin" | Out-Null
    New-Item -ItemType Directory -Path "$WorkspacePath\pkg" | Out-Null
    Write-Log "Created workspace directories"
}

# Set GOPATH environment variable
[System.Environment]::SetEnvironmentVariable("GOPATH", $WorkspacePath, [System.EnvironmentVariableTarget]::Machine)
Write-Log "GOPATH set to $WorkspacePath"

# 9. Configure Go environment
Write-Log "=== Step 9: Configuring Go Environment ==="
$env:GOPATH = $WorkspacePath
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install common Go tools
Write-Log "Installing common Go tools..."
$goTools = @(
    "golang.org/x/tools/gopls@latest",
    "github.com/go-delve/delve/cmd/dlv@latest",
    "honnef.co/go/tools/cmd/staticcheck@latest",
    "golang.org/x/tools/cmd/goimports@latest"
)
foreach ($tool in $goTools) {
    Write-Log "Installing $tool"
    go install $tool
}

# 10. Install additional development tools
Write-Log "=== Step 10: Installing Additional Development Tools ==="
choco install 7zip -y
choco install cmake -y
choco install ninja -y

# 11. Configure Windows Remote Desktop
Write-Log "=== Step 11: Configuring Remote Desktop ==="
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Log "Remote Desktop enabled"

# 12. Disable Windows Firewall for private networks (optional, for easier development)
Write-Log "=== Step 12: Configuring Windows Firewall ==="
Set-NetFirewallProfile -Profile Private -Enabled False
Write-Log "Windows Firewall disabled for private networks"

# 13. Set up automatic login (optional - comment out if not needed for security)
# Write-Log "=== Step 13: Configuring Automatic Login ==="
# Uncomment below lines and set your credentials if you want automatic login
# $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
# Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
# Set-ItemProperty $RegPath "DefaultUsername" -Value "YourUsername" -type String
# Set-ItemProperty $RegPath "DefaultPassword" -Value "YourPassword" -type String

# 14. Create a test Go program
Write-Log "=== Step 14: Creating Test Go Program ==="
$testProgram = @"
package main

import (
    "fmt"
    "runtime"
)

func main() {
    fmt.Println("=== Golang Environment Test ===")
    fmt.Printf("Go Version: %s\n", runtime.Version())
    fmt.Printf("Operating System: %s\n", runtime.GOOS)
    fmt.Printf("Architecture: %s\n", runtime.GOARCH)
    fmt.Printf("GOPATH: %s\n", runtime.GOROOT())
    fmt.Println("Environment setup successful!")
}
"@

$testProgramPath = "$WorkspacePath\src\test_env"
if (-not (Test-Path $testProgramPath)) {
    New-Item -ItemType Directory -Path $testProgramPath | Out-Null
}
$testProgram | Out-File -FilePath "$testProgramPath\main.go" -Encoding UTF8

Write-Log "Building test program..."
Push-Location $testProgramPath
go build -o test_env.exe
if ($LASTEXITCODE -eq 0) {
    Write-Log "Test program built successfully"
    Write-Log "Running test program..."
    .\test_env.exe
} else {
    Write-Log "Failed to build test program" "ERROR"
}
Pop-Location

# 15. Cleanup
Write-Log "=== Step 15: Cleanup ==="
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
    Write-Log "Cleaned up temp directory"
}

# 16. Create environment info file
Write-Log "=== Step 16: Creating Environment Info File ==="
$envInfo = @"
=== Golang Development Environment ===
Setup Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Installed Components:
- Golang Version: $GolangVersion
- Git: $(git --version)
- vcpkg Location: $VcpkgPath
- GOPATH: $WorkspacePath
- Visual Studio Build Tools: Installed
- Visual Studio Code: Installed

Environment Variables:
- GOPATH: $WorkspacePath
- VCPKG_ROOT: $VcpkgPath

Next Steps:
1. Remote connect to this machine using Remote Desktop
2. Open Visual Studio Code
3. Start developing!

For vcpkg usage:
  cd $VcpkgPath
  .\vcpkg.exe search <package-name>
  .\vcpkg.exe install <package-name>

For Go development:
  cd $WorkspacePath\src
  mkdir myproject
  cd myproject
  go mod init myproject
  code .
"@

$envInfo | Out-File -FilePath "C:\EnvironmentInfo.txt" -Encoding UTF8
Write-Log "Environment info saved to C:\EnvironmentInfo.txt"

Write-Log "=== Setup Complete ==="
Write-Log "Please restart the system for all changes to take effect"
Write-Log "Log file saved to C:\setup-log.txt"

# Display summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Setup Completed Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Log file: C:\setup-log.txt" -ForegroundColor Yellow
Write-Host "Environment info: C:\EnvironmentInfo.txt" -ForegroundColor Yellow
Write-Host "`nPlease restart the system to ensure all environment variables are loaded." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
