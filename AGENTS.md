# AGENTS.md - Development Guidelines

This document provides guidelines for agentic coding agents working in this repository.

## Project Overview

This repository contains practical, reproducible code analysis guidelines and shell scripts for automated code review, static analysis, and project health monitoring. It demonstrates best practices for:

- **Code Analysis**: Patterns and techniques for analyzing codebases programmatically
- **Static Analysis**: Using tools like shellcheck for script validation
- **Dependency Management**: Tracking and validating project dependencies
- **Health Checks**: Automated scripts for project health monitoring
- **Reproducibility**: Ensuring analysis results are consistent across environments

Use these scripts as templates for building your own code analysis workflows and CI/CD integrations.

## Build / Lint / Test Commands

### Linting

Use `shellcheck` for static analysis of bash scripts:

```bash
# Check all shell scripts
shellcheck scripts/*.sh

# Check specific file
shellcheck scripts/tallyman-report.sh
```

### Testing

This project uses Bats (Bash Automated Testing System) for testing:

```bash
# Install bats via uv
uv tool install bats-core

# Run all tests
bats tests/

# Run a single test file
bats tests/test_tallyman-report.bats

# Run a single test by name
bats tests/test_tallyman-report.bats --filter "test_name"
```

### Manual Testing

```bash
# Run the script directly
./scripts/tallyman-report.sh

# Enable debug mode (uncomment set -x in script or run with bash -x)
bash -x scripts/tallyman-report.sh
```

## Code Style Guidelines

### Shell Script Standards

- **Shebang**: Always use `#!/usr/bin/env bash` for portability
- **Strict mode**: Use `set -euo pipefail` at the top of all scripts
- **Quoting**: Always quote variables: `"$variable"`, not `$variable`
- **Functions**: Use lowercase with underscores: `my_function()`
- **Variables**: Use lowercase with underscores for local variables, UPPERCASE for constants
- **Local variables**: Declare with `local` inside functions

### Formatting

```bash
# Good
if [ -z "$variable" ]; then
    echo "Variable is empty"
fi

# Good - function definition
my_function() {
    local result
    result=$(command)
    echo "$result"
}

# Avoid - no quoting
if [ -z $variable ]; then
    echo $result
fi
```

### Error Handling

- Always check command exit codes
- Use `|| true` when commands may fail but script should continue
- Exit with descriptive error messages
- Use `trap` for cleanup when needed

```bash
# Good error handling
if ! command -v uv > /dev/null; then
    echo "Error: uv is not installed"
    exit 1
fi

# Handle optional failures
output=$(grep pattern file || true)
```

### Dependencies

- Check for required tools at script start
- Use `command -v` to check for binaries
- Document tool requirements in comments

### Naming Conventions

- **Scripts**: `kebab-case.sh`
- **Functions**: `snake_case()`
- **Variables**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private functions**: Prefix with underscore `_helper_function()`

### Imports and Dependencies

- No external imports in bash
- Source helper scripts with full paths or relative to script location

```bash
# Good - relative to script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/lib/helpers.sh"
```

### Comments

- Use `#` for comments
- Add brief header comments explaining script purpose
- Comment complex logic or non-obvious workarounds

```bash
#!/usr/bin/env bash
#
# tallyman-report.sh - Generates usage reports for tallyman metrics
#
# Requirements: uv tool
# Usage: ./tallyman-report.sh
```

### Output Formatting

- Use `echo ""` for blank lines
- Prefer simple messages for errors
- Use ANSI colors sparingly (check if terminal supports them)
- **Don't use emojis in the outputs** (use ASCII characters instead)

```bash
# Check if terminal supports colors
if [ -t 1 ]; then
    RED='\033[0;31m'
    NC='\033[0m' # No Color
fi

echo -e "${RED}Error:${NC} Something went wrong"
```

## PR Guidelines

- Test scripts with `shellcheck` before committing
- Test on both Linux (bash) and macOS (BSD tools may differ)
- Keep scripts focused on single responsibility
- Update this AGENTS.md if adding new tools or conventions

## External Tools Used

- **uv**: Python package and tool manager
- **tallyman-metrics**: Python tool installed via uv
- **shellcheck**: Static analysis for shell scripts
- **bats**: Bash testing framework (install via uv)
