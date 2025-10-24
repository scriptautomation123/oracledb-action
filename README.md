# Oracle Database GitHub Action 🔮

A comprehensive, enterprise-grade GitHub Action for running Oracle Database with automated setup, testing, cleanup, and security scanning. Perfect for CI/CD pipelines and database testing workflows.

## ✨ Features

- 🗄️ **Automated Oracle Database Deployment** - Spin up Oracle Database containers (versions 19-slim, 21-slim, 23-slim)
- 📝 **SQL Script Execution** - Run setup, test, and cleanup scripts automatically
- 🔒 **Security Scanning** - Built-in Checkov integration for SQL security analysis
- 🎯 **Flexible Configuration** - Customizable ports, passwords, and timeouts
- 📊 **Rich Reporting** - Detailed test summaries and GitHub Action outputs
- 🔄 **Reusable Workflows** - Both composite action and reusable workflow options
- 🚀 **Fast & Reliable** - Health checks ensure database is ready before running scripts
- 🧹 **Automatic Cleanup** - Database containers are always cleaned up after tests

## 🚀 Quick Start

### Using the Composite Action

```yaml
name: Oracle DB Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Oracle Database Tests
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: '21-slim'
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
          cleanup-scripts: 'sql/cleanup/*.sql'
          run-checkov: true
```

### Using the Reusable Workflow

```yaml
name: Oracle DB Pipeline

on: [push, pull_request]

jobs:
  oracle-tests:
    uses: scriptautomation123/oracledb-action/.github/workflows/oracle-db-reusable.yml@v1
    with:
      oracle-version: '21-slim'
      setup-scripts: 'sql/setup/*.sql'
      test-scripts: 'sql/tests/*.sql'
      cleanup-scripts: 'sql/cleanup/*.sql'
      run-checkov: true
    secrets:
      oracle-password: ${{ secrets.ORACLE_PASSWORD }}
```

## 📖 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `oracle-version` | Oracle Database version (19-slim, 21-slim, 23-slim) | No | `21-slim` |
| `setup-scripts` | Path to setup SQL scripts (glob pattern or comma-separated) | No | `''` |
| `test-scripts` | Path to test SQL scripts (glob pattern or comma-separated) | No | `''` |
| `cleanup-scripts` | Path to cleanup SQL scripts (glob pattern or comma-separated) | No | `''` |
| `oracle-password` | Password for SYS and SYSTEM users | No | `OraclePassword123` |
| `oracle-port` | Port to expose Oracle Database | No | `1521` |
| `wait-timeout` | Timeout in seconds to wait for Oracle to be ready | No | `300` |
| `run-checkov` | Run Checkov security scan on SQL scripts | No | `true` |
| `checkov-framework` | Checkov framework to use | No | `all` |
| `fail-on-checkov` | Fail the action if Checkov finds issues | No | `false` |
| `startup-health-check` | SQL query to verify database is ready | No | `SELECT 1 FROM DUAL` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `oracle-container-id` | Container ID of the Oracle Database |
| `oracle-status` | Status of Oracle Database operations |
| `checkov-results` | Checkov scan results summary |

## 📚 Advanced Usage Examples

### Matrix Testing with Multiple Oracle Versions

```yaml
jobs:
  test-matrix:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        oracle-version: ['19-slim', '21-slim', '23-slim']
    steps:
      - uses: actions/checkout@v4
      
      - name: Test Oracle ${{ matrix.oracle-version }}
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: ${{ matrix.oracle-version }}
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
```

### Security-Focused Pipeline

```yaml
jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Security Scan
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
          run-checkov: true
          fail-on-checkov: true  # Fail if security issues found
      
      - name: Upload Checkov SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results_sarif.sarif
```

### Custom Database Configuration

```yaml
jobs:
  custom-config:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run with Custom Config
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: '23-slim'
          oracle-port: '1522'
          oracle-password: ${{ secrets.ORACLE_PASSWORD }}
          wait-timeout: '600'
          setup-scripts: 'db/init/*.sql,db/seed/*.sql'
          test-scripts: 'tests/**/*.sql'
          cleanup-scripts: 'db/cleanup.sql'
```

## 📁 SQL Script Organization

### Recommended Directory Structure

```
your-repo/
├── sql/
│   ├── setup/
│   │   ├── 01_create_tables.sql
│   │   ├── 02_create_procedures.sql
│   │   └── 03_seed_data.sql
│   ├── tests/
│   │   ├── 01_test_tables.sql
│   │   ├── 02_test_procedures.sql
│   │   └── 03_test_data_integrity.sql
│   └── cleanup/
│       └── 01_cleanup_all.sql
└── .github/
    └── workflows/
        └── oracle-tests.yml
```

### Script Execution Order

Scripts are executed in the following order:

1. **Setup Scripts** - Create tables, procedures, functions, and seed data
2. **Test Scripts** - Run validation queries and tests
3. **Cleanup Scripts** - Drop objects and clean up (always runs, even if tests fail)

Scripts within each category are executed in alphabetical order, so use numeric prefixes (01_, 02_, etc.) to control execution order.

## 🔒 Security Best Practices

### 1. Use Secrets for Passwords

```yaml
with:
  oracle-password: ${{ secrets.ORACLE_PASSWORD }}
```

### 2. Enable Checkov Scanning

```yaml
with:
  run-checkov: true
  fail-on-checkov: true  # Fail on security issues
```

### 3. Review Checkov Results

The action uploads Checkov results as artifacts. Review them regularly:

```yaml
- name: Upload Checkov Results
  uses: actions/upload-artifact@v4
  with:
    name: security-scan-results
    path: results_*.json
```

### 4. Integrate with GitHub Security

```yaml
- name: Upload to Security Tab
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results_sarif.sarif
```

## 🛠️ SQL Script Examples

### Setup Script Example

```sql
-- setup/01_create_tables.sql
CREATE TABLE users (
    user_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

INSERT INTO users (username, email) 
VALUES ('admin', 'admin@example.com');

COMMIT;
```

### Test Script Example

```sql
-- tests/01_test_users.sql
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM users;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Test failed: No users found');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test passed: Found ' || v_count || ' users');
END;
/
```

### Cleanup Script Example

```sql
-- cleanup/01_cleanup.sql
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('✓ Cleanup complete');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN  -- Table doesn't exist
            RAISE;
        END IF;
END;
/
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Oracle Database Express Edition (XE) container by [gvenzl](https://github.com/gvenzl/oci-oracle-xe)
- [Checkov](https://www.checkov.io/) for security scanning
- GitHub Actions community

## 📞 Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/scriptautomation123/oracledb-action).

## 🗺️ Roadmap

- [ ] Support for Oracle RAC configurations
- [ ] Performance benchmarking tools
- [ ] Database migration testing
- [ ] Liquibase/Flyway integration
- [ ] Custom health check queries
- [ ] Parallel test execution
- [ ] Oracle Enterprise Edition support

---

**Made with ❤️ for database testing automation**