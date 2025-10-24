# Architecture Overview

This document provides a technical overview of the Oracle Database GitHub Action architecture.

## Components

### 1. Composite Action (`action.yml`)

The main entry point that orchestrates the entire testing workflow.

```
┌─────────────────────────────────────────────────────────────────┐
│                      action.yml (Composite Action)              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Validate   │  │  Setup Python│  │  Install     │         │
│  │   Inputs     │──▶│  & Oracle    │──▶│  Dependencies│         │
│  │              │  │  Client      │  │              │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│          │                                     │                │
│          ▼                                     ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Start      │  │   Wait for   │  │   Run        │         │
│  │   Oracle     │──▶│   Database   │──▶│   Checkov    │         │
│  │   Container  │  │   Ready      │  │   (Optional) │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│          │                                     │                │
│          ▼                                     ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Execute    │  │   Execute    │  │   Execute    │         │
│  │   Setup      │──▶│   Test       │──▶│   Cleanup    │         │
│  │   Scripts    │  │   Scripts    │  │   Scripts    │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│          │                                     │                │
│          ▼                                     ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Generate   │  │   Upload     │  │   Stop &     │         │
│  │   Summary    │──▶│   Artifacts  │──▶│   Cleanup    │         │
│  │              │  │              │  │   Container  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Reusable Workflow (`.github/workflows/oracle-db-reusable.yml`)

Provides a workflow-level abstraction for easier integration.

```
┌─────────────────────────────────────────────────────────────────┐
│              Reusable Workflow                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Inputs:                        Secrets:                        │
│  ├── oracle-version             ├── oracle-password             │
│  ├── setup-scripts              └── (other secrets)             │
│  ├── test-scripts                                               │
│  ├── cleanup-scripts                                            │
│  ├── run-checkov                                                │
│  └── fail-on-checkov                                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────┐      │
│  │         Calls action.yml                             │      │
│  │    (scriptautomation123/oracledb-action@v1)          │      │
│  └──────────────────────────────────────────────────────┘      │
│                          │                                      │
│                          ▼                                      │
│  ┌──────────────────────────────────────────────────────┐      │
│  │         Upload Artifacts                             │      │
│  │  ├── Checkov results                                 │      │
│  │  └── Test logs                                       │      │
│  └──────────────────────────────────────────────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3. SQL Execution Engine

Python-based SQL execution with support for glob patterns and PL/SQL blocks.

```
┌─────────────────────────────────────────────────────────────────┐
│                   SQL Execution Engine (Python)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  expand_paths(pattern) ────┐                                    │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────┐          │
│  │  Pattern Resolution                              │          │
│  │  ├── Glob patterns (*.sql)                       │          │
│  │  ├── Comma-separated lists                       │          │
│  │  └── Individual files                            │          │
│  └──────────────────────────────────────────────────┘          │
│                            │                                    │
│                            ▼                                    │
│  run_sql_file(filepath) ───┐                                    │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────┐          │
│  │  SQL Parsing & Execution                         │          │
│  │  ├── Split by semicolon                          │          │
│  │  ├── Execute each statement                      │          │
│  │  ├── Handle PL/SQL blocks                        │          │
│  │  └── Error reporting                             │          │
│  └──────────────────────────────────────────────────┘          │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────┐          │
│  │  cx_Oracle Connection                            │          │
│  │  ├── Connect to XEPDB1                           │          │
│  │  ├── Execute statements                          │          │
│  │  ├── Commit transactions                         │          │
│  │  └── Error handling                              │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Script Execution Flow

```
User Repository
    │
    ├── sql/setup/
    │   ├── 01_create_tables.sql ──┐
    │   └── 02_create_procedures.sql┘
    │                                │
    ├── sql/tests/                   │
    │   ├── 01_test_tables.sql ──┐   │
    │   └── 02_test_procedures.sql┘  │
    │                                │
    └── sql/cleanup/                 │
        └── 01_cleanup_all.sql ──┐   │
                                 │   │
                                 ▼   ▼
                        ┌─────────────────────┐
                        │  GitHub Action      │
                        └─────────────────────┘
                                 │
                                 ▼
                        ┌─────────────────────┐
                        │  Oracle Container   │
                        │  (gvenzl/oracle-xe) │
                        └─────────────────────┘
                                 │
                                 ▼
                        ┌─────────────────────┐
                        │  Results & Reports  │
                        │  ├── Test Summary   │
                        │  ├── Checkov Report │
                        │  └── Artifacts      │
                        └─────────────────────┘
```

### Security Scanning Flow

```
SQL Scripts
    │
    ▼
┌─────────────────────┐
│   Checkov Scanner   │
├─────────────────────┤
│  Frameworks:        │
│  ├── SQL Injection  │
│  ├── Secrets        │
│  ├── Best Practices │
│  └── Custom Rules   │
└─────────────────────┘
    │
    ├─────┬─────┬─────┐
    │     │     │     │
    ▼     ▼     ▼     ▼
  CLI   JSON  SARIF  JUnit
   │     │     │     │
   │     │     └─────┴──── GitHub Security Tab
   │     │
   │     └───────────────── Artifacts
   │
   └─────────────────────── Console Output
```

## Container Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    Container Lifecycle                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Start Container                                             │
│     docker run -d gvenzl/oracle-xe:21-slim                      │
│     ├── Expose port 1521                                        │
│     ├── Set ORACLE_PWD                                          │
│     └── Set ORACLE_CHARACTERSET                                 │
│                                                                 │
│  2. Health Check Loop                                           │
│     while [ $ELAPSED -lt $TIMEOUT ]; do                         │
│       docker exec oracle-db healthcheck.sh                      │
│     done                                                        │
│                                                                 │
│  3. Execute Scripts                                             │
│     ├── Setup Scripts                                           │
│     ├── Test Scripts                                            │
│     └── Cleanup Scripts (always runs)                           │
│                                                                 │
│  4. Stop & Remove (always runs)                                 │
│     docker stop oracle-db                                       │
│     docker rm oracle-db                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Integration Patterns

### Pattern 1: Direct Action Usage

```yaml
jobs:
  test:
    steps:
      - uses: actions/checkout@v4
      - uses: scriptautomation123/oracledb-action@v1
        with:
          setup-scripts: 'sql/setup/*.sql'
```

### Pattern 2: Reusable Workflow

```yaml
jobs:
  test:
    uses: scriptautomation123/oracledb-action/.github/workflows/oracle-db-reusable.yml@v1
    with:
      setup-scripts: 'sql/setup/*.sql'
```

### Pattern 3: Matrix Testing

```yaml
jobs:
  test:
    strategy:
      matrix:
        oracle-version: ['19-slim', '21-slim', '23-slim']
    steps:
      - uses: scriptautomation123/oracledb-action@v1
        with:
          oracle-version: ${{ matrix.oracle-version }}
```

## Technology Stack

- **Container Runtime**: Docker
- **Database**: Oracle Database Express Edition (XE)
- **Base Image**: gvenzl/oracle-xe
- **Python**: 3.11+
- **Oracle Client**: cx_Oracle
- **Security Scanner**: Checkov
- **CI/CD Platform**: GitHub Actions
- **Supported OS**: Ubuntu (GitHub Actions runner)

## Security Features

1. **Isolated Execution**: Database runs in isolated container
2. **Automatic Cleanup**: Container always removed after execution
3. **Secret Management**: Integration with GitHub Secrets
4. **Security Scanning**: Checkov integration for SQL vulnerability detection
5. **SARIF Output**: Compatible with GitHub Security tab
6. **Network Isolation**: Only specified ports exposed

## Performance Considerations

- **Startup Time**: 60-120 seconds (Oracle database initialization)
- **Script Execution**: Variable (depends on script complexity)
- **Checkov Scanning**: 30-60 seconds
- **Recommended Timeout**: 300-600 seconds
- **Runner Requirements**: 
  - 2GB+ RAM recommended
  - Docker support required
  - Ubuntu runner

## Extensibility

The action is designed to be extensible:

1. **Custom Health Checks**: Configure custom startup verification queries
2. **Multiple Script Paths**: Support for glob patterns and comma-separated lists
3. **Flexible Checkov**: Configurable frameworks and failure behavior
4. **Version Flexibility**: Support for multiple Oracle versions
5. **Output Integration**: Rich outputs for downstream jobs

## Best Practices

1. **Script Organization**: Use numeric prefixes for execution order
2. **Error Handling**: Include proper exception handling in PL/SQL
3. **Idempotent Cleanup**: Handle "object not found" errors gracefully
4. **Security First**: Enable Checkov scanning in production
5. **Version Pinning**: Use specific action versions (@v1)
6. **Secret Management**: Never hardcode passwords
