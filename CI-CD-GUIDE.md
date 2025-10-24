# CI/CD Integration Guide

This guide explains how to integrate the Oracle Database GitHub Action into various CI/CD scenarios.

## Table of Contents

- [Basic Integration](#basic-integration)
- [Advanced Scenarios](#advanced-scenarios)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Real-World Examples](#real-world-examples)

## Basic Integration

### Simple Database Testing

Add to `.github/workflows/test.yml`:

```yaml
name: Database Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Oracle Tests
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
          cleanup-scripts: 'sql/cleanup/*.sql'
```

## Advanced Scenarios

### Multi-Environment Testing

Test against multiple Oracle versions:

```yaml
name: Multi-Version Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        oracle-version: ['19-slim', '21-slim', '23-slim']
      fail-fast: false
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test Oracle ${{ matrix.oracle-version }}
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: ${{ matrix.oracle-version }}
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
          cleanup-scripts: 'sql/cleanup/*.sql'
      
      - name: Upload Results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results-${{ matrix.oracle-version }}
          path: results_*.json
```

### Integration with Other Services

Combine with application tests:

```yaml
name: Full Integration Tests

on: [push, pull_request]

jobs:
  database-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Database Tests
        id: db-test
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'db/migrations/*.sql'
          test-scripts: 'db/tests/*.sql'
      
      - name: Save Container ID
        if: success()
        run: echo "CONTAINER_ID=${{ steps.db-test.outputs.oracle-container-id }}" >> $GITHUB_ENV
  
  app-tests:
    needs: database-tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm install
      
      - name: Run Application Tests
        env:
          ORACLE_HOST: localhost
          ORACLE_PORT: 1521
          ORACLE_PASSWORD: ${{ secrets.ORACLE_PASSWORD }}
        run: npm test
```

### Deployment Pipeline

Use in deployment workflows:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  validate-sql:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate SQL Scripts
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'migrations/*.sql'
          run-checkov: true
          fail-on-checkov: true  # Block deployment on security issues
      
      - name: Upload Security Report
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results_sarif.sarif
  
  deploy:
    needs: validate-sql
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: echo "Deploying..."
```

## Best Practices

### 1. Use Branch Protection

Require database tests to pass before merging:

```yaml
# .github/workflows/pr-checks.yml
name: PR Checks

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  database-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run DB Tests
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/*.sql'
          run-checkov: true
          fail-on-checkov: true
```

Then in repository settings: Branches → Branch protection rules → Require status checks

### 2. Cache Dependencies

Speed up workflows by caching Python packages:

```yaml
- name: Cache Python dependencies
  uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

- name: Run Oracle Tests
  uses: scriptautomation123/oracledb-action@v1
```

### 3. Conditional Execution

Run tests only when SQL files change:

```yaml
on:
  pull_request:
    paths:
      - 'sql/**'
      - 'db/**'
      - '.github/workflows/db-tests.yml'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Oracle Tests
        uses: scriptautomation123/oracledb-action@v1
```

### 4. Secret Management

Store sensitive data securely:

```yaml
- name: Run Oracle Tests
  uses: scriptautomation123/oracledb-action@v1
  with:
    oracle-password: ${{ secrets.ORACLE_PASSWORD }}
  env:
    DB_CONNECTION_STRING: ${{ secrets.DB_CONNECTION_STRING }}
```

### 5. Parallel Testing

Run different test suites in parallel:

```yaml
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: scriptautomation123/oracledb-action@v1
        with:
          test-scripts: 'tests/unit/*.sql'
  
  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: scriptautomation123/oracledb-action@v1
        with:
          test-scripts: 'tests/integration/*.sql'
  
  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: scriptautomation123/oracledb-action@v1
        with:
          test-scripts: 'tests/performance/*.sql'
          wait-timeout: '600'
```

## Common Patterns

### Pattern 1: Development Workflow

```yaml
name: Development CI

on:
  push:
    branches-ignore: [ main ]

jobs:
  quick-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Quick Validation
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'sql/setup/01_*.sql'
          test-scripts: 'sql/tests/smoke/*.sql'
          run-checkov: false  # Skip for dev branches
```

### Pattern 2: Production Workflow

```yaml
name: Production CI

on:
  push:
    branches: [ main ]

jobs:
  comprehensive-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Comprehensive Testing
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: '21-slim'
          setup-scripts: 'sql/setup/*.sql'
          test-scripts: 'sql/tests/**/*.sql'
          cleanup-scripts: 'sql/cleanup/*.sql'
          run-checkov: true
          fail-on-checkov: true
          wait-timeout: '600'
```

### Pattern 3: Nightly Builds

```yaml
name: Nightly Tests

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily

jobs:
  full-suite:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        oracle-version: ['19-slim', '21-slim', '23-slim']
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Full Test Suite
        uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: ${{ matrix.oracle-version }}
          setup-scripts: 'sql/setup/**/*.sql'
          test-scripts: 'sql/tests/**/*.sql'
          cleanup-scripts: 'sql/cleanup/**/*.sql'
      
      - name: Notify on Failure
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: 'Nightly tests failed',
              body: 'Oracle ${{ matrix.oracle-version }} tests failed'
            })
```

## Real-World Examples

### Example 1: Microservice with Oracle Backend

```yaml
name: Microservice CI/CD

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      redis:
        image: redis
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Database
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'db/schema/*.sql,db/seed/*.sql'
          test-scripts: 'db/tests/*.sql'
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install and Test
        run: |
          npm ci
          npm test
        env:
          ORACLE_HOST: localhost
          ORACLE_PORT: 1521
          ORACLE_PASSWORD: OraclePassword123
          REDIS_URL: redis://localhost:6379
```

### Example 2: Database Migration Testing

```yaml
name: Migration Tests

on:
  pull_request:
    paths:
      - 'migrations/**'

jobs:
  test-migration:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Get all history
      
      - name: Get Changed Migrations
        id: changed-files
        run: |
          echo "files=$(git diff --name-only origin/main...HEAD migrations/ | tr '\n' ',')" >> $GITHUB_OUTPUT
      
      - name: Test New Migrations
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'migrations/baseline/*.sql'
          test-scripts: ${{ steps.changed-files.outputs.files }}
          cleanup-scripts: 'migrations/rollback/*.sql'
```

### Example 3: Data Pipeline Validation

```yaml
name: Data Pipeline Tests

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  validate-pipeline:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Test Data
        uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: |
            etl/setup/01_create_staging.sql,
            etl/setup/02_create_transform.sql,
            etl/setup/03_load_sample_data.sql
          test-scripts: |
            etl/tests/01_test_extraction.sql,
            etl/tests/02_test_transformation.sql,
            etl/tests/03_test_loading.sql
          cleanup-scripts: 'etl/cleanup/*.sql'
          wait-timeout: '900'  # 15 minutes for large datasets
```

## Monitoring and Reporting

### Send Results to Slack

```yaml
- name: Run Oracle Tests
  id: oracle-test
  uses: scriptautomation123/oracledb-action@v1

- name: Notify Slack
  if: always()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "Oracle Tests: ${{ steps.oracle-test.outputs.oracle-status }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Oracle Database Tests ${{ job.status }}\n${{ steps.oracle-test.outputs.checkov-results }}"
            }
          }
        ]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Generate Test Reports

```yaml
- name: Run Oracle Tests
  uses: scriptautomation123/oracledb-action@v1

- name: Publish Test Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always()
  with:
    files: results_*.json
    check_name: Oracle Database Tests
```

## Troubleshooting CI/CD

### Common Issues

1. **Timeout on Startup**
   ```yaml
   with:
     wait-timeout: '600'  # Increase timeout
   ```

2. **Resource Constraints**
   ```yaml
   # Use ubuntu-latest with more resources
   runs-on: ubuntu-latest
   ```

3. **Concurrent Runs**
   ```yaml
   concurrency:
     group: ${{ github.workflow }}-${{ github.ref }}
     cancel-in-progress: true
   ```

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Action Documentation](README.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
