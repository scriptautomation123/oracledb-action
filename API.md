# API Reference

Complete reference for all inputs, outputs, and configuration options.

## Action Inputs

### Database Configuration

#### `oracle-version`
- **Type**: String
- **Required**: No
- **Default**: `21-slim`
- **Description**: Oracle Database version to use
- **Valid Values**: 
  - `19-slim` - Oracle Database 19c Express Edition
  - `21-slim` - Oracle Database 21c Express Edition (recommended)
  - `23-slim` - Oracle Database 23c Express Edition (latest)
- **Example**:
  ```yaml
  with:
    oracle-version: '21-slim'
  ```

#### `oracle-password`
- **Type**: String (sensitive)
- **Required**: No
- **Default**: `OraclePassword123`
- **Description**: Password for SYS and SYSTEM database users
- **Security Note**: Use GitHub Secrets in production
- **Example**:
  ```yaml
  with:
    oracle-password: ${{ secrets.ORACLE_PASSWORD }}
  ```

#### `oracle-port`
- **Type**: String
- **Required**: No
- **Default**: `1521`
- **Description**: Port to expose Oracle Database on localhost
- **Valid Range**: 1024-65535
- **Example**:
  ```yaml
  with:
    oracle-port: '1522'
  ```

#### `wait-timeout`
- **Type**: String
- **Required**: No
- **Default**: `300`
- **Description**: Maximum seconds to wait for Oracle Database to be ready
- **Valid Range**: 60-600 (recommended)
- **Example**:
  ```yaml
  with:
    wait-timeout: '600'
  ```

#### `startup-health-check`
- **Type**: String
- **Required**: No
- **Default**: `SELECT 1 FROM DUAL`
- **Description**: SQL query to verify database is ready
- **Example**:
  ```yaml
  with:
    startup-health-check: 'SELECT COUNT(*) FROM dual'
  ```

### Script Configuration

#### `setup-scripts`
- **Type**: String
- **Required**: No
- **Default**: `''` (empty)
- **Description**: Path to SQL setup scripts
- **Formats Supported**:
  - Glob patterns: `sql/setup/*.sql`
  - Comma-separated: `setup1.sql,setup2.sql`
  - Mixed: `sql/init/*.sql,special.sql`
- **Execution Order**: Alphabetical
- **Example**:
  ```yaml
  with:
    setup-scripts: 'sql/setup/*.sql,db/seed/initial_data.sql'
  ```

#### `test-scripts`
- **Type**: String
- **Required**: No
- **Default**: `''` (empty)
- **Description**: Path to SQL test scripts
- **Formats Supported**: Same as setup-scripts
- **Execution Order**: Alphabetical
- **Example**:
  ```yaml
  with:
    test-scripts: 'tests/**/*.sql'
  ```

#### `cleanup-scripts`
- **Type**: String
- **Required**: No
- **Default**: `''` (empty)
- **Description**: Path to SQL cleanup scripts
- **Formats Supported**: Same as setup-scripts
- **Execution Condition**: Always runs, even if tests fail
- **Example**:
  ```yaml
  with:
    cleanup-scripts: 'sql/cleanup/*.sql'
  ```

### Security Configuration

#### `run-checkov`
- **Type**: String (boolean)
- **Required**: No
- **Default**: `true`
- **Description**: Enable Checkov security scanning
- **Valid Values**: `true`, `false`
- **Example**:
  ```yaml
  with:
    run-checkov: true
  ```

#### `checkov-framework`
- **Type**: String
- **Required**: No
- **Default**: `all`
- **Description**: Checkov framework to use for scanning
- **Valid Values**: `all`, `secrets`, `sca`, etc.
- **Example**:
  ```yaml
  with:
    checkov-framework: 'secrets'
  ```

#### `fail-on-checkov`
- **Type**: String (boolean)
- **Required**: No
- **Default**: `false`
- **Description**: Fail the action if Checkov finds security issues
- **Valid Values**: `true`, `false`
- **Recommendation**: Set to `true` for production pipelines
- **Example**:
  ```yaml
  with:
    fail-on-checkov: true
  ```

## Action Outputs

### `oracle-container-id`
- **Type**: String
- **Description**: Docker container ID of the Oracle Database instance
- **Use Cases**:
  - Advanced debugging
  - Custom container operations
  - Log retrieval
- **Example**:
  ```yaml
  - id: oracle-test
    uses: scriptautomation123/oracledb-action@v1
  
  - name: Get logs
    run: docker logs ${{ steps.oracle-test.outputs.oracle-container-id }}
  ```

### `oracle-status`
- **Type**: String
- **Description**: Status of Oracle Database test operations
- **Possible Values**: `success`, `failure`, or empty
- **Example**:
  ```yaml
  - id: oracle-test
    uses: scriptautomation123/oracledb-action@v1
  
  - name: Check status
    if: steps.oracle-test.outputs.oracle-status == 'success'
    run: echo "Tests passed!"
  ```

### `checkov-results`
- **Type**: String
- **Description**: Summary of Checkov security scan results
- **Format**: Multi-line text summary
- **Example**:
  ```yaml
  - id: oracle-test
    uses: scriptautomation123/oracledb-action@v1
  
  - name: Display security results
    run: |
      echo "Security Scan Results:"
      echo "${{ steps.oracle-test.outputs.checkov-results }}"
  ```

## Workflow Integration

### Reusable Workflow Inputs

When using `.github/workflows/oracle-db-reusable.yml`:

#### `oracle-version`
- **Type**: String
- **Required**: No
- **Default**: `21-slim`

#### `setup-scripts`
- **Type**: String
- **Required**: No
- **Default**: `sql/setup/*.sql`

#### `test-scripts`
- **Type**: String
- **Required**: No
- **Default**: `sql/tests/*.sql`

#### `cleanup-scripts`
- **Type**: String
- **Required**: No
- **Default**: `sql/cleanup/*.sql`

#### `run-checkov`
- **Type**: Boolean
- **Required**: No
- **Default**: `true`

#### `fail-on-checkov`
- **Type**: Boolean
- **Required**: No
- **Default**: `false`

#### `working-directory`
- **Type**: String
- **Required**: No
- **Default**: `.`

### Reusable Workflow Secrets

#### `oracle-password`
- **Type**: Secret
- **Required**: No
- **Default**: `OraclePassword123` (if not provided)
- **Example**:
  ```yaml
  jobs:
    test:
      uses: scriptautomation123/oracledb-action/.github/workflows/oracle-db-reusable.yml@v1
      secrets:
        oracle-password: ${{ secrets.ORACLE_PASSWORD }}
  ```

## Artifacts Generated

The action generates the following artifacts (when applicable):

### `results_json.json`
- Checkov scan results in JSON format
- Generated when: `run-checkov: true`

### `results_sarif.sarif`
- Checkov scan results in SARIF format
- Generated when: `run-checkov: true`
- Compatible with GitHub Security tab

### `checkov_summary.txt`
- Human-readable summary of Checkov results
- Generated when: `run-checkov: true`

## Environment Variables

The action uses the following environment variables internally:

### `ORACLE_PASSWORD`
- Set during script execution
- Contains the oracle-password input value

### `ORACLE_PORT`
- Set during script execution
- Contains the oracle-port input value

## Exit Codes

- `0` - Success
- `1` - General failure (database startup, script execution, etc.)
- `Other` - Specific error codes from tools (Checkov, Docker, etc.)

## Resource Requirements

### Minimum Requirements
- **RAM**: 2GB
- **Disk**: 5GB
- **CPU**: 2 cores
- **OS**: Ubuntu (GitHub Actions runner)

### Recommended Requirements
- **RAM**: 4GB
- **Disk**: 10GB
- **CPU**: 2+ cores

## Rate Limits

- **Docker Hub**: Action uses public Oracle XE images
  - Anonymous: 100 pulls per 6 hours
  - Authenticated: 200 pulls per 6 hours
- **GitHub Actions**: Standard GitHub Actions limits apply

## Version Compatibility

| Component | Version |
|-----------|---------|
| GitHub Actions | Latest |
| Ubuntu Runner | 20.04, 22.04 |
| Python | 3.11+ |
| Docker | 20.10+ |
| Oracle XE | 19c, 21c, 23c |

## Feature Support Matrix

| Feature | Supported | Notes |
|---------|-----------|-------|
| Glob patterns | ✅ | All script inputs |
| PL/SQL blocks | ✅ | Full support |
| Multiple versions | ✅ | 19c, 21c, 23c |
| Checkov scanning | ✅ | Optional |
| SARIF output | ✅ | For GitHub Security |
| Matrix testing | ✅ | Multiple versions |
| Secrets support | ✅ | GitHub Secrets |
| Custom health checks | ✅ | Via startup-health-check |
| Auto cleanup | ✅ | Always runs |

## Examples by Use Case

### Basic Testing
```yaml
uses: scriptautomation123/oracledb-action@v1
with:
  setup-scripts: 'db/setup.sql'
  test-scripts: 'db/tests.sql'
```

### Production Security
```yaml
uses: scriptautomation123/oracledb-action@v1
with:
  oracle-password: ${{ secrets.ORACLE_PASSWORD }}
  run-checkov: true
  fail-on-checkov: true
```

### Complex Setup
```yaml
uses: scriptautomation123/oracledb-action@v1
with:
  oracle-version: '23-slim'
  oracle-port: '1522'
  wait-timeout: '600'
  setup-scripts: 'sql/migrations/*.sql,sql/seed/*.sql'
  test-scripts: 'tests/**/*.sql'
  cleanup-scripts: 'sql/cleanup.sql'
```

### Multi-Version Testing
```yaml
strategy:
  matrix:
    oracle: ['19-slim', '21-slim', '23-slim']
steps:
  - uses: scriptautomation123/oracledb-action@v1
    with:
      oracle-version: ${{ matrix.oracle }}
```

## Troubleshooting

For detailed troubleshooting information, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Support

- 📖 [Full Documentation](README.md)
- 🏗️ [Architecture Guide](ARCHITECTURE.md)
- 🚀 [Quick Start](QUICKSTART.md)
- 🐛 [Report Issues](https://github.com/scriptautomation123/oracledb-action/issues)
