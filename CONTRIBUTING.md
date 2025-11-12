# Contributing to OnetimeGolangEnv

Thank you for your interest in contributing to OnetimeGolangEnv! We welcome contributions from the community.

## How to Contribute

### Reporting Issues

If you encounter a bug or have a feature request:

1. Check if the issue already exists in [GitHub Issues](https://github.com/zaixia108/OnetimeGolangEnv/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Your environment details (Windows version, Proxmox version, etc.)
   - Relevant logs from `C:\setup-log.txt`

### Submitting Changes

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/OnetimeGolangEnv.git
   cd OnetimeGolangEnv
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make Your Changes**
   - Follow existing code style
   - Test your changes thoroughly
   - Update documentation as needed

4. **Test Your Changes**
   - For PowerShell scripts: Test on actual Windows VM
   - For bash scripts: Test on Proxmox host
   - Verify no syntax errors
   - Check that automation still works end-to-end

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

6. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then create a Pull Request on GitHub

### Code Style Guidelines

#### PowerShell Scripts

- Use proper indentation (4 spaces)
- Include comments for complex logic
- Use `Write-Log` function for logging
- Handle errors appropriately
- Follow PowerShell best practices:
  ```powershell
  # Good
  $variable = Get-Something
  if ($variable) {
      Write-Log "Success"
  }
  
  # Use approved verbs (Get, Set, New, etc.)
  ```

#### Bash Scripts

- Use 4 spaces for indentation
- Include shebang: `#!/bin/bash`
- Use `set -e` for error handling
- Add comments for complex sections
- Use functions for reusable code
- Follow bash best practices:
  ```bash
  # Good
  VARIABLE="value"
  if [[ -n "$VARIABLE" ]]; then
      echo "Success"
  fi
  ```

#### Documentation

- Write in clear, concise English and/or Chinese
- Include examples where helpful
- Update README.md if adding new features
- Keep formatting consistent

### What to Contribute

We welcome contributions in these areas:

#### High Priority
- Bug fixes
- Performance improvements
- Better error handling
- Additional Windows versions support
- Security improvements

#### Medium Priority
- New features (discuss in issue first)
- Additional automation options
- Improved documentation
- Translations
- Example configurations

#### Ideas
- Support for other hypervisors (VMware, Hyper-V)
- Container-based alternatives
- CI/CD integration examples
- Monitoring and management tools
- Pre-configured development environments

### Testing Checklist

Before submitting a PR, ensure:

- [ ] Code syntax is valid (no syntax errors)
- [ ] Scripts run without errors on target platform
- [ ] Documentation is updated
- [ ] Changes are tested on actual VM/Proxmox
- [ ] No breaking changes (or documented if necessary)
- [ ] Commit messages are clear and descriptive
- [ ] Code follows project style guidelines

### Pull Request Process

1. Ensure your PR description clearly describes the problem and solution
2. Include the relevant issue number if applicable
3. Update the README.md with details of changes if needed
4. The PR will be reviewed by maintainers
5. Address any feedback or requested changes
6. Once approved, your PR will be merged

### Development Environment Setup

To contribute, you'll need:

1. **For PowerShell Development:**
   - Windows VM with PowerShell 5.1+
   - Visual Studio Code with PowerShell extension
   - Git for Windows

2. **For Bash Development:**
   - Linux system or WSL
   - Bash 4.0+
   - Access to Proxmox VE for testing

3. **For Documentation:**
   - Markdown editor
   - Basic understanding of Git

### Community Guidelines

- Be respectful and constructive
- Help others in issues and discussions
- Follow the code of conduct
- Give credit where due
- Collaborate openly

### Questions?

- Open a [Discussion](https://github.com/zaixia108/OnetimeGolangEnv/discussions)
- Comment on relevant issues
- Check existing documentation first

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior

- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what is best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Publishing others' private information
- Other conduct that could be considered inappropriate

### Enforcement

Violations may result in temporary or permanent ban from the project.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Release notes (for significant contributions)
- README.md (for major features)

Thank you for contributing to OnetimeGolangEnv! 🚀
