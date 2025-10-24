# 🚀 Oracle Database Action - Quickstart Guide

Get up and running with the Oracle Database GitHub Action in minutes!

## 📋 Prerequisites

- GitHub repository with Actions enabled
- SQL scripts for database setup, testing, and cleanup
- Basic understanding of GitHub Actions workflows

## 🎯 Quick Setup (30 seconds)

### 1. Create Your Workflow File

Create `.github/workflows/oracle-test.yml` in your repository:

```yaml
name: Oracle Database Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test with Oracle Database
        uses: scriptautomation123/oracledb-action@main
        with:
          oracle-version: 21-slim
          setup-scripts: sql/setup/*.sql
          test-scripts: sql/tests/*.sql
          cleanup-scripts: sql/cleanup/*.sql
```

### 2. Organize Your SQL Scripts

```
your-repo/
├── sql/
│   ├── setup/
│   │   ├── 01_create_tables.sql
│   │   └── 02_insert_data.sql
│   ├── tests/
│   │   ├── 01_test_queries.sql
│   │   └── 02_test_procedures.sql
│   └── cleanup/
│       └── 01_cleanup_all.sql
└── .github/workflows/
    └── oracle-test.yml
```

### 3. That's It! 🎉

Push your changes and watch your Oracle Database tests run automatically.

---

## 🔧 Configuration Optio

### Oracle Versions Available
- `21-slim` (recommended, default)
- `23-slim` (latest features)
- `19-slim` (LTS version)

### Basic Configuration

```yaml
- name: Oracle DB Test
  uses: scriptautomation123/oracledb-action@main
  with:
    # Database version
    oracle-version: 21-slim
    
    # SQL script paths (glob patterns supported)
    setup-scripts: sql/setup/*.sql
    test-scripts: sql/tests/*.sql
    cleanup-scripts: sql/cleanup/*.sql
    
    # Connection settings
    oracle-password: OraclePassword123  # Default password
    wait-timeout: 300                   # Container startup timeout
    
    # Security scanning
    run-checkov: true                   # Enable security checks
    fail-on-checkov: false             # Don't fail on security warnings
```

### Advanced Configuration

```yaml
- name: Advanced Oracle Testing
  uses: scriptautomation123/oracledb-action@main
  with:
    oracle-version: 23-slim
    setup-scripts: |
      database/schema/*.sql
      database/data/*.sql
    test-scripts: tests/**/*.sql
    cleanup-scripts: cleanup/drop_all.sql
    
    # SQL*Plus commands for advanced testing
    sqlplus-commands: |
      SELECT 'Database Status: ' || STATUS FROM V$INSTANCE;
      SELECT COUNT(*) as "Total Tables" FROM USER_TABLES;
      EXEC DBMS_STATS.GATHER_SCHEMA_STATS(USER);
    
    # Security and compliance
    run-checkov: true
    checkov-framework: dockerfile,secrets,yaml
    fail-on-checkov: true
    
    # Performance tuning
    wait-timeout: 600
    oracle-password: ${{ secrets.ORACLE_PASSWORD }}
```

---

## 📚 Workflow Examples

This repository includes several pre-configured workflow examples:

### 🔄 Development Workflow (`ci.yml`)
- **Purpose**: Fast validation for every commit
- **Triggers**: Push to main/develop/feature branches, PRs
- **Features**: Action validation, shell script checks, code quality with Trunk
- **Runtime**: ~2-3 minutes

```yaml
# Lightweight CI - runs on every change
on:
  push:
    branches: [main, develop, feature/**]
  pull_request:
    branches: [main, develop]
```

### 📋 Example Usage (`example-usage.yml`)
- **Purpose**: Comprehensive usage demonstrations
- **Triggers**: Changes to action files, manual trigger, weekly schedule
- **Features**: 4 different usage patterns, matrix testing, security scans
- **Runtime**: ~15-20 minutes

### 🚀 Production Usage (`production-usage.yml`)
- **Purpose**: Production-ready testing strategy
- **Triggers**: Manual dispatch, scheduled runs
- **Features**: Multi-environment testing, performance monitoring
- **Runtime**: ~10-15 minutes

### 🏷️ Release Workflow (`release.yml`)
- **Purpose**: Comprehensive testing before releases
- **Triggers**: Version tags (`v*.*.*`), manual dispatch
- **Features**: Matrix testing (all Oracle versions), security compliance, automated releases
- **Runtime**: ~25-30 minutes

### 🔄 Reusable Workflow (`oracle-db-reusable.yml`)
- **Purpose**: Shareable workflow for other repositories
- **Usage**: Call from other workflows with `uses: ./.github/workflows/oracle-db-reusable.yml`

---

## 🎯 Common Use Cases

### 1. Simple Database Testing
```yaml
- uses: scriptautomation123/oracledb-action@main
  with:
    setup-scripts: create_tables.sql
    test-scripts: run_tests.sql
    cleanup-scripts: drop_tables.sql
```

### 2. Multi-Version Testing
```yaml
strategy:
  matrix:
    oracle-version: [19-slim, 21-slim, 23-slim]

steps:
  - uses: scriptautomation123/oracledb-action@main
    with:
      oracle-version: ${{ matrix.oracle-version }}
      setup-scripts: sql/setup/*.sql
      test-scripts: sql/tests/*.sql
```

### 3. Security-First Testing
```yaml
- uses: scriptautomation123/oracledb-action@main
  with:
    oracle-version: 21-slim
    setup-scripts: sql/setup/*.sql
    test-scripts: sql/tests/*.sql
    run-checkov: true
    fail-on-checkov: true
    checkov-framework: dockerfile,secrets,yaml
```

### 4. Performance Testing
```yaml
- uses: scriptautomation123/oracledb-action@main
  with:
    oracle-version: 21-slim
    setup-scripts: sql/schema.sql
    test-scripts: sql/performance/*.sql
    sqlplus-commands: |
      SET TIMING ON
      SET AUTOTRACE ON
      @sql/benchmark.sql
      SELECT * FROM V$SESSTAT WHERE SID = SYS_CONTEXT('USERENV','SID');
```

---

## 🛠️ Development Tools

### Code Quality (Trunk Integration)
The repository includes automated code quality tools:

```bash
# Run all quality checks
./scripts/trunk.sh

# Check specific files
trunk check .github/workflows/

# Auto-fix issues
trunk check --fix --all
```

### YAML Formatting
Clean up YAML files automatically:

```bash
# Clean specific file
./scripts/quick-yaml-clean.sh .github/workflows/my-workflow.yml

# Clean all workflow files
./scripts/clean-yaml-whitespace.sh
```

---

## 🔍 Troubleshooting

### Common Issues

1. **Container startup timeout**
   ```yaml
   with:
     wait-timeout: 600  # Increase timeout
   ```

2. **SQL script not found**
   ```yaml
   with:
     setup-scripts: ./sql/setup/*.sql  # Use explicit path
   ```

3. **Permission denied**
   ```yaml
   permissions:
     contents: read
     actions: read
   ```

4. **Security scan failures**
   ```yaml
   with:
     fail-on-checkov: false  # Don't fail on warnings
   ```

### Debug Mode
Enable verbose logging:

```yaml
- uses: scriptautomation123/oracledb-action@main
  with:
    oracle-version: 21-slim
    setup-scripts: sql/*.sql
  env:
    RUNNER_DEBUG: 1
```

---

## 📊 Workflow Triggering Strategies

### Development (Frequent)
```yaml
on:
  push:
    branches: [main, develop]
    paths: ['src/**', 'sql/**']
  pull_request:
    branches: [main]
```

### Production (Selective)
```yaml
on:
  push:
    tags: ['v*.*.*']
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM
  workflow_dispatch:
```

### Feature Branches (On-Demand)
```yaml
on:
  push:
    branches: ['feature/**']
  workflow_dispatch:
```

---

## 🚀 Next Steps

1. **Start Simple**: Use the basic configuration above
2. **Add Security**: Enable Checkov scanning with `run-checkov: true`
3. **Scale Up**: Add matrix testing for multiple Oracle versions
4. **Optimize**: Use path-based triggering to reduce CI runs
5. **Monitor**: Set up notifications for workflow failures

### 📖 Additional Resources

- [Full Action Documentation](API.md)
- [Architecture Overview](ARCHITECTURE.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

### 💡 Pro Tips

- Use `21-slim` for the best balance of features and performance
- Organize SQL scripts with numeric prefixes (`01_`, `02_`, etc.) for execution order
- Enable security scanning in production workflows
- Use matrix testing sparingly to avoid resource waste
- Set appropriate `wait-timeout` values based on your database complexity

---

---

## ✅ Validation & Testing

### 🧪 Method 1: Use the Built-in Examples

The repository includes complete validation examples you can use immediately:

```bash
# Clone this repository
git clone https://github.com/scriptautomation123/oracledb-action.git
cd oracledb-action

# Run the example workflow manually
gh workflow run example-usage.yml

# Or trigger via the GitHub UI:
# Actions > Example Oracle DB Test Workflow > Run workflow
```

The built-in examples include:
- ✅ **Table Creation Tests** (`examples/sql/setup/01_create_tables.sql`)
- ✅ **Constraint Validation** (`examples/sql/tests/01_test_tables.sql`)
- ✅ **Procedure Testing** (`examples/sql/tests/02_test_procedures.sql`)
- ✅ **Cleanup Verification** (`examples/sql/cleanup/01_cleanup_all.sql`)

### 🔧 Method 2: Quick Local Validation

Test the action directly in this repository:

```yaml
# Create .github/workflows/validate-action.yml
name: Validate Oracle Action

on:
  workflow_dispatch:
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test Action with Examples
        uses: ./  # Use local action
        with:
          oracle-version: 21-slim
          setup-scripts: examples/sql/setup/*.sql
          test-scripts: examples/sql/tests/*.sql
          cleanup-scripts: examples/sql/cleanup/*.sql
          run-checkov: true
```

### 🎯 Method 3: Fork and Customize

1. **Fork this repository** to your GitHub account
2. **Modify the example SQL scripts** in `examples/sql/` for your use case
3. **Run the workflows** to see your customizations in action
4. **Copy the working configuration** to your main project

### 🚀 Method 4: Direct Integration Test

Test in your own repository immediately:

```yaml
# .github/workflows/test-oracle-action.yml
name: Test Oracle Database Action

on: 
  workflow_dispatch:

jobs:
  test-oracle-action:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      
    steps:
      - uses: actions/checkout@v4
      
      # Create test SQL files inline
      - name: Create test SQL scripts
        run: |
          mkdir -p sql/{setup,tests,cleanup}
          
          # Setup script
          cat > sql/setup/01_setup.sql << 'EOF'
          CREATE TABLE validation_test (
            id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            test_name VARCHAR2(100),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
          INSERT INTO validation_test (test_name) VALUES ('Action Validation Test');
          COMMIT;
          EOF
          
          # Test script  
          cat > sql/tests/01_test.sql << 'EOF'
          DECLARE
            v_count NUMBER;
          BEGIN
            SELECT COUNT(*) INTO v_count FROM validation_test;
            IF v_count = 0 THEN
              RAISE_APPLICATION_ERROR(-20001, 'No test data found!');
            END IF;
            DBMS_OUTPUT.PUT_LINE('✓ Validation test passed: ' || v_count || ' records found');
          END;
          /
          EOF
          
          # Cleanup script
          cat > sql/cleanup/01_cleanup.sql << 'EOF'
          DROP TABLE validation_test;
          EOF
      
      - name: Run Oracle Database Tests
        uses: scriptautomation123/oracledb-action@main
        with:
          oracle-version: 21-slim
          setup-scripts: sql/setup/*.sql
          test-scripts: sql/tests/*.sql
          cleanup-scripts: sql/cleanup/*.sql
```

### 🔍 Method 5: Step-by-Step Validation

Manual verification process:

```bash
# 1. Check action structure
cat action.yml | head -20

# 2. Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('action.yml'))"

# 3. Run code quality checks
./scripts/trunk.sh

# 4. Test example scripts locally (if you have Oracle installed)
sqlplus hr/hr@localhost:1521/xe @examples/sql/setup/01_create_tables.sql

# 5. Validate workflow syntax
for file in .github/workflows/*.yml; do
  echo "Checking $file..."
  python3 -c "import yaml; yaml.safe_load(open('$file'))"
done
```

### 📊 Method 6: Monitor Existing Workflows

Watch the repository's own workflows for validation:

1. **CI Workflow** (`ci.yml`): Runs on every push
   - Validates action structure
   - Checks shell script syntax  
   - Runs code quality tools

2. **Example Usage** (`example-usage.yml`): Comprehensive testing
   - Tests actual Oracle database functionality
   - Demonstrates 4 different usage patterns
   - Includes security scanning

3. **Release Workflow** (`release.yml`): Full validation
   - Matrix testing across Oracle versions
   - Security compliance checks
   - Real-world usage scenarios

### 🔧 Validation Checklist

Use this checklist to validate your setup:

- [ ] **Action loads successfully** (no YAML syntax errors)
- [ ] **Oracle container starts** (within timeout period)
- [ ] **Setup scripts execute** (tables/procedures created)
- [ ] **Test scripts pass** (validation logic succeeds)
- [ ] **Cleanup scripts work** (resources properly cleaned up)
- [ ] **Security scan passes** (if enabled)
- [ ] **Logs are readable** (proper output formatting)
- [ ] **Artifacts uploaded** (if configured)

### 🚨 Common Validation Issues

**Container won't start:**
```yaml
with:
  wait-timeout: 600  # Increase timeout
  oracle-version: 21-slim  # Try different version
```

**SQL scripts fail:**
```yaml
with:
  setup-scripts: ./sql/setup/*.sql  # Use explicit paths
```

**Permission errors:**
```yaml
permissions:
  contents: read
  actions: read
```

**Security scan failures:**
```yaml
with:
  fail-on-checkov: false  # Don't fail on warnings initially
```

### 💡 Pro Validation Tips

1. **Start with the examples** - They're proven to work
2. **Test incrementally** - Add one script at a time  
3. **Check the logs** - Action provides detailed output
4. **Use different Oracle versions** - Test compatibility
5. **Enable debug mode** - Set `RUNNER_DEBUG: 1` for verbose logs
6. **Validate locally first** - Test SQL syntax before pushing

---

## 🖥️ GitHub CLI for Actions Management

### 🔐 Initial Setup

```bash
# Authenticate with GitHub
gh auth login

# Set your preferred editor (optional)
gh config set editor code  # or nano, vim, etc.

# Verify authentication
gh auth status
```

### 📋 Essential Workflow Commands

#### **List & View Workflows**
```bash
# List all workflows in current repo
gh workflow list

# View workflow details
gh workflow view "Release & Full Testing"
gh workflow view release.yml

# View workflow runs (recent activity)
gh run list

# View specific run details
gh run view <run-id>
```

#### **🚀 Trigger Workflows**
```bash
# Run workflow_dispatch workflows
gh workflow run "Example Oracle DB Test Workflow"
gh workflow run example-usage.yml

# Run with inputs (if workflow has inputs)
gh workflow run release.yml -f test_matrix=true -f create_release=false

# Run on specific branch
gh workflow run ci.yml --ref feature/my-branch
```

#### **📊 Monitor Workflow Runs**
```bash
# Watch a running workflow in real-time
gh run watch

# List recent runs with status
gh run list --limit 10

# View logs for a specific run
gh run view <run-id> --log

# Download run artifacts
gh run download <run-id>

# Cancel a running workflow
gh run cancel <run-id>
```

### 🎯 Oracle Action Specific Commands

For this Oracle Database Action repository:

```bash
# Quick validation - run the CI workflow
gh workflow run ci.yml

# Full testing - run example usage
gh workflow run example-usage.yml

# Production testing
gh workflow run production-usage.yml

# Release testing (manual trigger)
gh workflow run release.yml -f test_matrix=true -f create_release=false
```

### 🔍 Debugging & Troubleshooting

```bash
# View failed runs
gh run list --status failure

# Get detailed logs for debugging
gh run view <run-id> --log --log-failed

# Re-run failed jobs
gh run rerun <run-id>

# Re-run only failed jobs
gh run rerun <run-id> --failed
```

### 📈 Workflow Status & Monitoring

```bash
# Check workflow status (great for scripts)
gh workflow view ci.yml --json | jq '.state'

# Get run status programmatically
gh run list --json | jq '.[] | {id: .databaseId, status: .status, conclusion: .conclusion}'

# Monitor specific workflow
gh run list --workflow=ci.yml --limit 5
```

### 🛠️ Repository Management

```bash
# View repository secrets (names only, not values)
gh secret list

# Set a secret (for Oracle password, etc.)
gh secret set ORACLE_PASSWORD

# View repository variables
gh variable list

# Create/update variable
gh variable set ORACLE_VERSION --body "21-slim"
```

### 🚀 Advanced Usage

#### **Bulk Operations**
```bash
# Run multiple workflows
for workflow in ci.yml example-usage.yml; do
  echo "Running $workflow..."
  gh workflow run "$workflow"
done

# Check status of all recent runs
gh run list --json | jq '.[] | "\(.workflowName): \(.status)"'
```

#### **Integration with Scripts**
```bash
#!/bin/bash
# automated-test.sh

echo "🚀 Running Oracle Database Action validation..."

# Run the example workflow
RUN_ID=$(gh workflow run example-usage.yml --json | jq -r '.id')

# Wait for completion and get status
while true; do
  STATUS=$(gh run view $RUN_ID --json | jq -r '.status')
  if [[ "$STATUS" == "completed" ]]; then
    CONCLUSION=$(gh run view $RUN_ID --json | jq -r '.conclusion')
    echo "✅ Workflow completed with: $CONCLUSION"
    break
  fi
  echo "⏳ Waiting for workflow to complete..."
  sleep 30
done
```

#### **Workflow Templates**
```bash
# Create a new workflow from template
gh workflow create

# Enable/disable workflows
gh workflow disable ci.yml
gh workflow enable ci.yml
```

### 💡 Pro Tips for Oracle Action

1. **Quick Validation**:
   ```bash
   # Test your changes quickly
   gh workflow run ci.yml && gh run watch
   ```

2. **Debug Failed Tests**:
   ```bash
   # Get logs from failed Oracle tests
   gh run list --status failure --limit 1 --json | jq -r '.[0].databaseId' | xargs gh run view --log
   ```

3. **Matrix Testing**:
   ```bash
   # Run full matrix test (all Oracle versions)
   gh workflow run release.yml -f test_matrix=true
   ```

4. **Security Monitoring**:
   ```bash
   # Check security scan results
   gh run list --workflow=production-usage.yml --json | jq '.[] | select(.conclusion=="failure")'
   ```

5. **Performance Tracking**:
   ```bash
   # Track workflow execution times
   gh run list --json | jq '.[] | {workflow: .workflowName, duration: .timing.run_duration_ms}'
   ```

### 🔗 Useful Aliases

Add these to your shell profile:

```bash
# ~/.bashrc or ~/.zshrc
alias ghw='gh workflow'
alias ghr='gh run'
alias ghwl='gh workflow list'
alias ghrl='gh run list'
alias ghwatch='gh run watch'

# Oracle Action specific
alias test-oracle='gh workflow run example-usage.yml'
alias test-ci='gh workflow run ci.yml'
alias test-prod='gh workflow run production-usage.yml'
```

### 📚 Reference Commands

```bash
# Quick reference card
gh workflow --help
gh run --help

# View all available commands
gh --help

# Get help for specific command
gh workflow run --help
```

---

**Ready to get started?** Copy the quick setup example above and customize it for your needs! 🎯