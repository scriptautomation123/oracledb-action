# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-24

### Added
- Initial release of Oracle Database GitHub Action
- Composite action for running Oracle Database in CI/CD pipelines
- Support for Oracle Database versions: 19-slim, 21-slim, 23-slim
- Automatic execution of setup, test, and cleanup SQL scripts
- Integrated Checkov security scanning for SQL scripts
- Health check validation before running scripts
- Automatic container cleanup after workflow completion
- Reusable workflow for easy integration
- Comprehensive documentation and examples
- Example SQL scripts for common database operations
- Multiple usage examples including matrix testing
- Rich test reporting via GitHub Actions summary
- Security policy and best practices documentation
- Troubleshooting guide
- MIT License

### Features
- **Database Management**
  - Automated Oracle Database container deployment
  - Configurable Oracle versions
  - Custom port and password configuration
  - Health check with configurable timeout
  - Automatic startup verification

- **Script Execution**
  - Glob pattern support for script paths
  - Comma-separated file lists
  - Ordered execution (alphabetical)
  - Python-based SQL execution engine
  - PL/SQL block support
  - Transaction management

- **Security**
  - Checkov integration for security scanning
  - Support for GitHub Secrets
  - SARIF output for GitHub Security tab
  - Configurable security failure behavior
  - Container isolation

- **Reporting**
  - GitHub Actions summary integration
  - Test execution logs
  - Checkov results summary
  - Artifact uploads for detailed reports
  - Action outputs for container ID and status

### Documentation
- Comprehensive README with examples
- Security policy (SECURITY.md)
- Contributing guidelines (CONTRIBUTING.md)
- Troubleshooting guide (TROUBLESHOOTING.md)
- MIT License
- Example workflows
- Example SQL scripts

### Supported Oracle Versions
- Oracle Database 19c Express Edition (19-slim)
- Oracle Database 21c Express Edition (21-slim)
- Oracle Database 23c Express Edition (23-slim)

### Requirements
- GitHub Actions runner with Ubuntu
- Docker support
- Python 3.11+
- Oracle Instant Client dependencies (auto-installed)

[1.0.0]: https://github.com/scriptautomation123/oracledb-action/releases/tag/v1.0.0
