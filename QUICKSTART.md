# Quick Start Guide

Get up and running with Oracle Database testing in minutes!

## Step 1: Create Your SQL Scripts

Create a directory structure in your repository:

```bash
mkdir -p sql/{setup,tests,cleanup}
```

## Step 2: Add Your Setup Script

Create `sql/setup/01_create_tables.sql`:

```sql
-- Create a test table
CREATE TABLE users (
    user_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO users (username, email) VALUES ('testuser', 'test@example.com');
COMMIT;
```

## Step 3: Add Your Test Script

Create `sql/tests/01_test_users.sql`:

```sql
-- Test that the table exists and has data
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

## Step 4: Add Your Cleanup Script

Create `sql/cleanup/01_cleanup.sql`:

```sql
-- Drop the test table
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('✓ Cleanup complete');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN  -- Ignore "table doesn't exist"
            RAISE;
        END IF;
END;
/
```

## Step 5: Create Your Workflow

Create `.github/workflows/oracle-tests.yml`:

```yaml
name: Oracle Database Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Run Oracle Database Tests
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: '21-slim'
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
          cleanup-scripts: 'sql/cleanup/*.sql'
          run-checkov: true
```

## Step 6: Commit and Push

```bash
git add .
git commit -m "Add Oracle database tests"
git push
```

## Step 7: Watch Your Tests Run!

Go to your repository's Actions tab on GitHub to see your tests running.

## Next Steps

### Add More Tests

Create additional test files:
- `sql/tests/02_test_data_integrity.sql`
- `sql/tests/03_test_procedures.sql`

### Test Multiple Oracle Versions

```yaml
strategy:
  matrix:
    oracle-version: ['21-slim', '23-slim']
steps:
  - uses: scriptautomation123/oracledb-action@v1
    with:
      oracle-version: ${{ matrix.oracle-version }}
```

### Add Security Scanning

```yaml
- uses: scriptautomation123/oracledb-action@v1
  with:
    run-checkov: true
    fail-on-checkov: true  # Fail on security issues

- name: Upload Security Results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: results_sarif.sarif
```

### Use Secrets for Passwords

1. Go to your repository Settings → Secrets → Actions
2. Add a new secret: `ORACLE_PASSWORD`
3. Use it in your workflow:

```yaml
with:
  oracle-password: ${{ secrets.ORACLE_PASSWORD }}
```

## Common Use Cases

### Integration Tests

```yaml
- name: Run Integration Tests
  uses: scriptautomation123/oracledb-action@v1
  with:
    setup-scripts: 'db/migrations/*.sql,db/seed/*.sql'
    test-scripts: 'tests/integration/*.sql'
```

### Performance Testing

```yaml
- name: Performance Tests
  uses: scriptautomation123/oracledb-action@v1
  with:
    oracle-version: '23-slim'
    setup-scripts: 'perf/setup/*.sql'
    test-scripts: 'perf/benchmark/*.sql'
    wait-timeout: '600'  # Allow more time for large datasets
```

### Migration Testing

```yaml
- name: Test Database Migrations
  uses: scriptautomation123/oracledb-action@v1
  with:
    setup-scripts: 'migrations/v1/*.sql,migrations/v2/*.sql'
    test-scripts: 'tests/verify-migration.sql'
```

## Troubleshooting

### Tests Failing?

1. Check the Action logs for detailed error messages
2. Verify your SQL syntax is correct
3. Ensure scripts are in the correct directories
4. See the [Troubleshooting Guide](TROUBLESHOOTING.md) for more help

### Need Help?

- 📖 [Full Documentation](README.md)
- 🐛 [Report an Issue](https://github.com/scriptautomation123/oracledb-action/issues)
- 💬 [Discussions](https://github.com/scriptautomation123/oracledb-action/discussions)

## Tips for Success

1. **Start Simple** - Begin with basic tests, add complexity gradually
2. **Use Numeric Prefixes** - Name files `01_`, `02_`, etc. to control execution order
3. **Test Locally First** - Validate SQL syntax before pushing
4. **Handle Errors** - Use proper exception handling in cleanup scripts
5. **Review Logs** - Check Action logs to understand what happened
6. **Keep Scripts Small** - Break large scripts into smaller, focused files

## Example Repository

Check out the `examples/` directory in this repository for complete working examples!

Happy Testing! 🎉
