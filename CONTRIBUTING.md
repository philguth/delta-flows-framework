# Contributing to Delta Flows Framework

Thank you for your interest in contributing to the Delta Flows Framework! This guide will help you get started.

## 🤝 How to Contribute

### Reporting Issues
- Use the [Issues](https://github.com/philguth/delta-flows-framework/issues) tab to report bugs
- Search existing issues before creating a new one
- Provide detailed information including:
  - Steps to reproduce
  - Expected vs actual behavior
  - Environment details (Power Platform version, etc.)
  - Screenshots if applicable

### Suggesting Enhancements
- Use the [Discussions](https://github.com/philguth/delta-flows-framework/discussions) tab for feature requests
- Explain the use case and benefits
- Consider backward compatibility

### Code Contributions

#### Getting Started
1. Fork the repository
2. Clone your fork locally
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit with descriptive messages
7. Push to your fork
8. Create a Pull Request

#### Pull Request Guidelines
- **Title**: Clear, descriptive title
- **Description**: Explain what changes you made and why
- **Testing**: Describe how you tested your changes
- **Documentation**: Update documentation if needed
- **Breaking Changes**: Clearly mark any breaking changes

## 📋 Development Guidelines

### Code Standards
- Follow Power Platform best practices
- Use meaningful names for flows, entities, and variables
- Include comprehensive documentation in flows
- Implement proper error handling

### Solution Structure
- Keep customizations in appropriate files
- Maintain environment variable patterns
- Follow naming conventions:
  - Entities: `trz_[descriptivename]`
  - Environment Variables: `envvar_[PurposeDescription]`
  - Flows: Descriptive names with clear purpose

### Testing
- Test in development environment before submitting
- Verify environment variable functionality
- Test connection references work properly
- Validate flows execute successfully

## 🔧 Development Environment Setup

### Prerequisites
- Power Platform environment
- Power Platform CLI
- Git
- PowerShell 5.1 or PowerShell Core

### Setup Steps
1. Clone the repository
2. Run `.\Setup-EnvironmentVariables.ps1` to configure your environment
3. Import the solution to your development environment
4. Make and test your changes
5. Export the solution with your updates

## 📖 Documentation

### Required Documentation Updates
- Update README.md for new features
- Modify deployment guides if process changes
- Add inline documentation to flows
- Update PowerShell script help text

### Documentation Standards
- Use clear, concise language
- Include examples where helpful
- Keep documentation up to date with code changes
- Use proper Markdown formatting

## 🏷️ Versioning

We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## 🎯 Areas for Contribution

### High Priority
- [ ] Additional connector support (beyond SQL Server)
- [ ] Enhanced error handling and retry logic
- [ ] Performance optimizations
- [ ] Security enhancements

### Medium Priority
- [ ] Power BI integration for monitoring
- [ ] Azure Key Vault integration
- [ ] Multi-tenant support
- [ ] Advanced logging capabilities

### Low Priority
- [ ] Additional deployment automation
- [ ] Alternative authentication methods
- [ ] Custom connector examples
- [ ] UI improvements

## 💬 Communication

- **Questions**: Use [Discussions](https://github.com/philguth/delta-flows-framework/discussions)
- **Bugs**: Use [Issues](https://github.com/philguth/delta-flows-framework/issues)
- **Security**: Email security@[your-domain].com for security vulnerabilities

## 📄 Code of Conduct

### Our Standards
- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Focus on what's best for the community

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Public or private harassment
- Publishing private information without permission

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- GitHub contributors list

Thank you for contributing to the Delta Flows Framework!