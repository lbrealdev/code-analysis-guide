# code-analysis-guide

A wrapper script to automate the creation of codebase reports using [tallyman](https://github.com/mikeckennedy/tallyman) (available as `tallyman-metrics` on PyPI).

### Usage

```bash
./scripts/tallyman-report.sh [directory]
```

If no directory is specified, the script analyzes the current directory. The script automatically checks for `uv`, installs `tallyman-metrics` if needed, and generates a markdown report.