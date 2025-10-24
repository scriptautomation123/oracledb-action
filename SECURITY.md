# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability within this GitHub Action, please send an email to the repository maintainers. All security vulnerabilities will be promptly addressed.

Please do not open public issues for security vulnerabilities.

## Security Features

This action includes several security features:

### 1. Checkov Security Scanning

The action automatically scans SQL scripts using Checkov to identify:
- SQL injection vulnerabilities
- Insecure configurations
- Hardcoded credentials
- Other security issues

### 2. Secure Password Handling

- Passwords should be stored as GitHub Secrets
- Default passwords are only for testing purposes
- Production deployments must use custom passwords

### 3. Network Isolation

- Oracle Database runs in an isolated Docker container
- Only specified ports are exposed
- Container is automatically removed after tests

## Best Practices

1. **Always use GitHub Secrets** for sensitive data like passwords
2. **Enable Checkov scanning** in your workflows (`run-checkov: true`)
3. **Set `fail-on-checkov: true`** for production pipelines
4. **Review Checkov results** regularly via artifacts
5. **Keep the action updated** to the latest version
6. **Use principle of least privilege** for database users
7. **Avoid hardcoding credentials** in SQL scripts

## Security Configuration Example

```yaml
- name: Run Secure Oracle Tests
  uses: scriptautomation123/oracledb-action@v1
  with:
    oracle-password: ${{ secrets.ORACLE_PASSWORD }}
    run-checkov: true
    fail-on-checkov: true
    
- name: Upload Security Results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results_sarif.sarif
```

## Known Limitations

- This action is designed for testing and CI/CD purposes
- Not recommended for production database deployments
- Database data is ephemeral and lost when container stops

## Updates and Patches

Security updates are released as needed. Subscribe to repository releases to stay informed about security patches.
