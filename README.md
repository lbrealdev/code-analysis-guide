# code-analysis-guide

A wrapper script to automate the creation of codebase reports using [tallyman](https://github.com/mikeckennedy/tallyman) (available as `tallyman-metrics` on PyPI).

### Usage

```shell
.tallyman-report.sh path/to/repository
```

If no directory is specified, the script analyzes the current directory. The script automatically checks for `uv`, installs `tallyman-metrics` if needed, and generates a markdown report.
