#!/usr/bin/env bash

# tallyman wrapper
# source: https://github.com/mikeckennedy/tallyman

set -euo pipefail

TALLYMAN_CONFIG_FILE=".tally-config.toml"
REPORTS_DIR="reports"

print_banner() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                     TALLYMAN REPORT                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

check_dependencies() {
  if ! command -v uv > /dev/null; then
    echo "uv is not installed or not in PATH."
    exit 1
  fi
}

tallyman_install() {
  local uv_tool
  uv_tool=$(uv tool list | grep -oE "tallyman-metrics v[0-9]+\.[0-9]+\.[0-9]+" || true)

  if [ -z "$uv_tool" ]; then
    echo "tallyman-metrics not found, installing..."
    uv tool install tallyman-metrics -p 3.14 -q
    echo "tallyman-metrics installed successfully"
  fi
}

tallyman_config() {
  if [ ! -f "$TALLYMAN_CONFIG_FILE" ]; then
    echo "$TALLYMAN_CONFIG_FILE not found, creating..."
    cat << EOF > "$TALLYMAN_CONFIG_FILE"
[exclude]
directories = [
]
EOF
    echo "$TALLYMAN_CONFIG_FILE created successfully"
  fi
}

tallyman_report() {
  local target_dir="${1:-.}"
  local original_dir
  original_dir="$(pwd)"

  # Check if directory exists
  if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' not found"
    exit 1
  fi

  # Check if it's a git repository
  if [ ! -d "$target_dir/.git" ]; then
    echo "Error: '$target_dir' is not a git repository"
    exit 1
  fi

  echo "Git repository detected at: $target_dir"
  echo "Generating report..."

  # Change to target directory if specified
  if [ "$target_dir" != "." ]; then
    if ! cd "$target_dir"; then
      echo "Error: Failed to change to directory '$target_dir'"
      exit 1
    fi
  fi

  # Install and configure
  check_dependencies
  tallyman_install
  tallyman_config

  # Create reports directory in original execution directory
  if [ ! -d "${original_dir}/${REPORTS_DIR}" ]; then
    mkdir -p "${original_dir}/${REPORTS_DIR}"
    echo "Created ${REPORTS_DIR}/ directory"
  fi

  # Generate the actual report
  local repo_name repo_branch
  repo_name=$(basename "$(git rev-parse --show-toplevel)")
  repo_branch=$(git branch --show-current)

  tallyman --no-color > "${original_dir}/${REPORTS_DIR}/${repo_name}_${repo_branch}_report.md"

  # Clean up config file if we created it
  if [ -f "$TALLYMAN_CONFIG_FILE" ]; then
    rm "$TALLYMAN_CONFIG_FILE"
    echo "Cleaned up $TALLYMAN_CONFIG_FILE"
  fi

  # Return to original directory
  cd "$original_dir"

  echo "Report generated successfully: ${original_dir}/${REPORTS_DIR}/${repo_name}_${repo_branch}_report.md"
}

main() {
  print_banner
  
  # Parse arguments (basic support for now, -p flag in future)
  local target_dir="."
  
  if [ $# -ge 1 ]; then
    target_dir="$1"
  fi
  
  tallyman_report "$target_dir"
}

main "$@"
