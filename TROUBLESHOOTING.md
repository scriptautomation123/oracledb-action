# Troubleshooting Guide

This guide helps you resolve common issues when using the Oracle Database GitHub Action.

## Common Issues

### 1. Oracle Database Fails to Start

**Symptoms:**
- Action fails with "Oracle Database failed to start within X seconds"
- Container health check never passes

**Solutions:**

1. **Increase wait timeout:**
   ```yaml
   with:
     wait-timeout: '600'  # Increase from default 300
   ```

2. **Check runner resources:**
   - Oracle Database requires at least 2GB RAM
   - Ensure GitHub runner has sufficient resources

3. **Verify Oracle version:**
   ```yaml
   with:
     oracle-version: '21-slim'  # Try different versions
   ```

4. **Check Docker logs:**
   The action displays container logs on failure. Review them for specific errors.

### 2. SQL Scripts Fail to Execute

**Symptoms:**
- Script execution fails with syntax errors
- Connection errors to the database

**Solutions:**

1. **Verify SQL syntax:**
   - Test scripts locally with Oracle SQL Developer
   - Ensure no syntax errors in SQL files

2. **Check script paths:**
   ```yaml
   with:
     setup-scripts: 'sql/setup/*.sql'  # Verify path exists
   ```

3. **Review script execution order:**
   - Scripts execute in alphabetical order
   - Use numeric prefixes: `01_`, `02_`, etc.

4. **Check for PL/SQL blocks:**
   - Ensure PL/SQL blocks end with `/`
   - Example:
     ```sql
     BEGIN
       -- code
     END;
     /
     ```

### 3. Connection Issues

**Symptoms:**
- "Cannot connect to Oracle Database"
- "ORA-12154: TNS:could not resolve the connect identifier"

**Solutions:**

1. **Verify password:**
   ```yaml
   with:
     oracle-password: ${{ secrets.ORACLE_PASSWORD }}
   ```

2. **Check port configuration:**
   ```yaml
   with:
     oracle-port: '1521'  # Default Oracle port
   ```

3. **Service name:**
   - The action uses service name `XEPDB1` (Oracle XE default)
   - Don't change unless using custom configuration

### 4. Checkov Scan Issues

**Symptoms:**
- Checkov scan fails or hangs
- Unexpected security findings

**Solutions:**

1. **Disable Checkov temporarily:**
   ```yaml
   with:
     run-checkov: false
   ```

2. **Review Checkov results:**
   - Download artifacts to see detailed findings
   - Address legitimate security concerns

3. **Adjust failure behavior:**
   ```yaml
   with:
     fail-on-checkov: false  # Don't fail on Checkov issues
   ```

### 5. Performance Issues

**Symptoms:**
- Action takes too long to complete
- Timeouts during script execution

**Solutions:**

1. **Optimize SQL scripts:**
   - Reduce data seeding volume
   - Use batch operations
   - Add indexes for queries

2. **Split large scripts:**
   - Break into smaller files
   - Execute in parallel when possible

3. **Use lighter Oracle version:**
   ```yaml
   with:
     oracle-version: '21-slim'  # Lightest option
   ```

### 6. Cleanup Doesn't Run

**Symptoms:**
- Test objects remain in database
- Subsequent runs fail due to existing objects

**Solutions:**

1. **Check cleanup scripts:**
   - Verify scripts drop all created objects
   - Use `CASCADE CONSTRAINTS` for tables
   - Handle "object not found" errors gracefully

2. **Example cleanup with error handling:**
   ```sql
   BEGIN
     EXECUTE IMMEDIATE 'DROP TABLE my_table CASCADE CONSTRAINTS';
   EXCEPTION
     WHEN OTHERS THEN
       IF SQLCODE != -942 THEN  -- Ignore "table doesn't exist"
         RAISE;
       END IF;
   END;
   /
   ```

### 7. Permission Errors

**Symptoms:**
- "ORA-01031: insufficient privileges"
- Cannot create objects

**Solutions:**

1. **Grant necessary privileges:**
   - The action connects as SYSTEM user
   - Should have all necessary privileges
   - If using custom users, grant appropriate rights

2. **Check tablespace quotas:**
   ```sql
   ALTER USER system QUOTA UNLIMITED ON USERS;
   ```

### 8. GitHub Actions Workflow Issues

**Symptoms:**
- Action not found
- Invalid workflow syntax

**Solutions:**

1. **Verify action reference:**
   ```yaml
   uses: scriptautomation123/oracledb-action@v1  # Correct
   # NOT: uses: oracledb-action@v1  # Wrong
   ```

2. **Check workflow syntax:**
   - Use YAML validator
   - Ensure proper indentation
   - Verify input types match

3. **Use correct workflow type:**
   - Composite action: `uses: scriptautomation123/oracledb-action@v1`
   - Reusable workflow: `uses: scriptautomation123/oracledb-action/.github/workflows/oracle-db-reusable.yml@v1`

## Debugging Tips

### Enable Debug Logging

Set repository secret or variable:
```yaml
env:
  ACTIONS_STEP_DEBUG: true
```

### View Container Logs

The action automatically displays Oracle container logs on failure. Review these for specific error messages.

### Test Scripts Locally

Before using in CI/CD, test scripts locally:

```bash
docker run -d --name oracle-test \
  -p 1521:1521 \
  -e ORACLE_PWD=YourPassword \
  gvenzl/oracle-xe:21-slim

# Wait for database to start
docker exec oracle-test healthcheck.sh

# Connect and test
docker exec -it oracle-test sqlplus system/YourPassword@XEPDB1
```

### Check Script Paths

Verify files exist at specified paths:
```bash
ls -la sql/setup/*.sql
ls -la sql/tests/*.sql
ls -la sql/cleanup/*.sql
```

### Validate SQL Syntax

Use SQL*Plus or Oracle SQL Developer to validate syntax before committing:
```bash
sqlplus system/password@database @your_script.sql
```

## Getting Help

If you're still experiencing issues:

1. **Check existing issues:** Search [GitHub Issues](https://github.com/scriptautomation123/oracledb-action/issues)
2. **Review documentation:** Check the [README](README.md) for examples
3. **Open an issue:** Provide:
   - Action version
   - Workflow configuration
   - Error messages
   - Relevant logs
   - Steps to reproduce

## Useful Resources

- [Oracle Database Express Edition](https://www.oracle.com/database/technologies/appdev/xe.html)
- [Oracle SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/)
- [Checkov Documentation](https://www.checkov.io/1.Welcome/What%20is%20Checkov.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Performance Benchmarks

Typical execution times:

| Operation | Time |
|-----------|------|
| Oracle startup | 60-120 seconds |
| Simple script execution | 1-5 seconds |
| Complex setup (10+ tables) | 10-30 seconds |
| Checkov scan | 30-60 seconds |
| Total workflow | 2-5 minutes |

These times may vary based on runner resources and script complexity.
