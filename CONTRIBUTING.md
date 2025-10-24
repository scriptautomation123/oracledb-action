# Contributing to Oracle Database GitHub Action

Thank you for considering contributing to this project! This document provides guidelines for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your environment (OS, Oracle version, GitHub Actions runner)
- Relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:
- A clear description of the enhancement
- Why this enhancement would be useful
- Examples of how it would be used
- Any potential drawbacks or considerations

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the code style guidelines
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Submit a pull request** with a clear description

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/scriptautomation123/oracledb-action.git
   cd oracledb-action
   ```

2. Make your changes to the action

3. Test locally using act or a test repository

## Code Style Guidelines

### YAML Files

- Use 2 spaces for indentation
- Add comments for complex logic
- Keep lines under 120 characters
- Use descriptive names for inputs/outputs

### SQL Scripts

- Use uppercase for SQL keywords
- Add comments for complex queries
- Include proper error handling in PL/SQL blocks
- Use consistent naming conventions

### Documentation

- Update README.md for user-facing changes
- Add inline comments for complex logic
- Include examples for new features
- Keep documentation up to date

## Testing

Before submitting a pull request:

1. **Test the action** with different Oracle versions
2. **Verify all script paths** work correctly
3. **Test Checkov integration** with sample SQL files
4. **Check error handling** for edge cases
5. **Validate documentation** accuracy

### Testing Checklist

- [ ] Action runs successfully with default inputs
- [ ] Custom inputs work as expected
- [ ] Error handling works properly
- [ ] Cleanup runs even when tests fail
- [ ] Documentation is accurate
- [ ] Examples work correctly

## Commit Messages

Write clear, descriptive commit messages:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests when relevant

Examples:
```
Add support for Oracle 23c
Fix cleanup script execution order
Update README with new examples
```

## Project Structure

```
oracledb-action/
├── action.yml                          # Main composite action
├── .github/
│   └── workflows/
│       ├── oracle-db-reusable.yml     # Reusable workflow
│       └── example-usage.yml          # Example workflow
├── examples/
│   └── sql/
│       ├── setup/                     # Example setup scripts
│       ├── tests/                     # Example test scripts
│       └── cleanup/                   # Example cleanup scripts
├── README.md                          # Main documentation
├── SECURITY.md                        # Security policy
├── CONTRIBUTING.md                    # This file
└── .gitignore                         # Git ignore rules
```

## Adding New Features

When adding new features:

1. **Check for existing issues** to avoid duplicate work
2. **Discuss major changes** in an issue first
3. **Maintain backward compatibility** when possible
4. **Add tests and examples** for new features
5. **Update all relevant documentation**

## Code Review Process

1. A maintainer will review your pull request
2. Feedback will be provided for any needed changes
3. Once approved, the pull request will be merged
4. Your contribution will be included in the next release

## Recognition

All contributors will be recognized in the project. Thank you for helping make this action better!

## Questions?

Feel free to open an issue with your questions or reach out to the maintainers.

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).
