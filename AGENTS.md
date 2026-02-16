# AGENTS.md

## Lint

```bash
shellcheck tallyman-report.sh
```

## Script: tallyman-report.sh

A wrapper for [tallyman](https://github.com/mikeckennedy/tallyman) that generates codebase reports.

**Usage:**
```bash
./tallyman-report.sh [directory]
```

**Features:**
- Auto-installs `uv` and `tallyman-metrics` if missing
- Creates `reports/` subdirectory for output
- Generates `{repo_name}_{branch}_report.md`
- Cleans up temporary `.tally-config.toml` after run
- Uses `trap` for error recovery

**Dependencies:**
- `uv`
- `tallyman-metrics` (auto-installed)

## Code Style

- **Shebang:** `#!/usr/bin/env bash`
- **Strict mode:** `set -euo pipefail`
- **Quoting:** Always quote variables: `"$variable"`
- **Functions:** `snake_case()`
- **Constants:** `UPPER_SNAKE_CASE`
- **Cleanup:** Use `trap` for cleanup
- **Output:** No emojis, use ASCII only
