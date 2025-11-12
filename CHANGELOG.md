# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-12

### Added
- Initial release of OnetimeGolangEnv
- Automated PowerShell setup script (`setup-golang-env.ps1`) with features:
  - Automatic installation of Golang (default version 1.21.5)
  - Git version control system installation
  - Visual Studio Build Tools (MSBuildTools) installation
  - vcpkg C++ package manager installation and integration
  - Visual Studio Code installation with Go extensions
  - CMake and Ninja build tools installation
  - Automatic Go workspace setup
  - Common Go tools installation (gopls, delve, staticcheck, goimports)
  - Remote Desktop automatic enablement
  - Test program creation and verification
  - Comprehensive logging system
  - Environment information file generation
- Comprehensive Proxmox VE setup guide (`proxmox-setup-guide.md`):
  - Step-by-step VM creation instructions
  - Template creation and management
  - VirtIO drivers installation guide
  - Network configuration examples
  - Firewall rules configuration
  - Backup and snapshot recommendations
  - Troubleshooting section
  - Security best practices
- Bulk deployment script (`examples/bulk-deploy.sh`):
  - Automated multiple VM creation from template
  - Configurable VM naming and numbering
  - Optional automatic VM startup
  - Progress tracking and error handling
  - Deployment summary reporting
- VM configuration template (`examples/vm-config.json`):
  - Recommended hardware configurations
  - Network settings examples
  - Software version specifications
  - Firewall rules templates
  - Maintenance and monitoring guidelines
- Quick Start Guide (`QUICKSTART.md`):
  - 5-minute deployment guide
  - Step-by-step instructions
  - Bilingual (English and Chinese) documentation
  - Common FAQ section
- Comprehensive README (`README.md`):
  - Project overview and features
  - Installation instructions
  - Usage examples
  - Bilingual documentation
- Contributing guidelines (`CONTRIBUTING.md`):
  - Code style guidelines
  - Testing checklist
  - Pull request process
  - Community guidelines
- MIT License (`LICENSE`)
- Git ignore file (`.gitignore`)

### Features
- **Complete Automation**: One-click setup of entire development environment
- **Scalability**: Easy deployment of multiple identical environments
- **Customization**: Configurable versions and installation paths
- **Bilingual Support**: Full English and Chinese documentation
- **Production Ready**: Includes security, backup, and monitoring guidelines

### Technical Details
- Supports Windows Server 2019/2022 and Windows 10/11
- Compatible with Proxmox VE 7.0+
- Uses Chocolatey package manager for Windows software
- VirtIO drivers for optimal performance
- UEFI boot support
- Cloud-init compatible (optional)

### Documentation
- Complete setup guides in both English and Chinese
- Detailed Proxmox VE configuration instructions
- Troubleshooting guides for common issues
- Security recommendations
- Performance optimization tips

### Requirements
- Proxmox VE 7.0 or higher
- Windows Server 2019/2022 or Windows 10/11 ISO
- Minimum 100GB storage per VM
- 4+ CPU cores (8 recommended)
- 8GB+ RAM (16GB recommended)
- Network connectivity

## [Unreleased]

### Planned Features
- Support for Linux-based Golang development environments
- Docker container alternative
- Pre-configured IDE settings and extensions
- CI/CD integration examples
- Monitoring and management dashboard
- Support for other hypervisors (VMware, Hyper-V)
- Automated update scripts
- Multi-language Go project templates

### Under Consideration
- Cloud provider templates (AWS, Azure, GCP)
- Kubernetes development environment
- Integrated testing framework
- Performance benchmarking tools
- Remote collaboration features

## Notes

### Version Numbering
- MAJOR version for incompatible API changes
- MINOR version for new functionality in a backwards compatible manner
- PATCH version for backwards compatible bug fixes

### Getting Involved
We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Support
- GitHub Issues: https://github.com/zaixia108/OnetimeGolangEnv/issues
- Discussions: https://github.com/zaixia108/OnetimeGolangEnv/discussions
