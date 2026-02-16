#!/usr/bin/env bash
#
# tallyman-report.sh - Wrapper script to automate codebase reports using tallyman
# 
# This script wraps tallyman-metrics (https://github.com/mikeckennedy/tallyman) to:
# - Check for and install required dependencies (uv, tallyman-metrics)
# - Create temporary configuration if needed
# - Generate markdown reports in a reports/ subdirectory
# - Clean up temporary files after execution
#
# Usage: ./tallyman-report.sh [directory]
#   If no directory is specified, analyzes the current directory.
#

set -euo pipefail

# Configuration constants
TALLYMAN_CONFIG_FILE=".tally-config.toml"
REPORTS_DIR="reports"

# Cleanup state variables - track what we created for proper cleanup
_cleanup_config_created="false"
_cleanup_original_dir=""

# cleanup() - Trap handler that runs on EXIT to ensure proper cleanup
# Always removes config file if we created it (while still in target dir), then returns to original directory
# This runs even if the script fails or exits early
cleanup() {
  local exit_code=$?
  
  # Clean up config file FIRST (while still in target directory)
  if [ "$_cleanup_config_created" = "true" ] && [ -f "$TALLYMAN_CONFIG_FILE" ]; then
    rm "$TALLYMAN_CONFIG_FILE"
    echo "Cleaned up $TALLYMAN_CONFIG_FILE"
  fi
  
  # THEN return to original directory
  if [ -n "$_cleanup_original_dir" ] && [ "$(pwd)" != "$_cleanup_original_dir" ]; then
    cd "$_cleanup_original_dir" || true
  fi
  
  return $exit_code
}

# print_banner() - Display the script header banner
print_banner() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                     TALLYMAN REPORT                           ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

# check_dependencies() - Verify that required tools are installed
# Exits with error if uv is not available
check_dependencies() {
  if ! command -v uv > /dev/null; then
    echo "Error: uv is not installed or not in PATH."
    exit 1
  fi
}

# tallyman_install() - Check if tallyman-metrics is installed, install if missing
# Uses uv tool to check installed tools and install if needed
tallyman_install() {
  local uv_tool
  uv_tool=$(uv tool list | grep -oE "tallyman-metrics v[0-9]+\.[0-9]+\.[0-9]+" || true)

  if [ -z "$uv_tool" ]; then
    echo "tallyman-metrics not found, installing..."
    uv tool install tallyman-metrics -p 3.14 -q
    echo "tallyman-metrics installed successfully"
  fi
}

# tallyman_config() - Create tallyman config file if it doesn't exist
# Sets _cleanup_config_created flag so cleanup() knows to remove it later
# Preserves existing user config files
tallyman_config() {
  if [ ! -f "$TALLYMAN_CONFIG_FILE" ]; then
    echo "$TALLYMAN_CONFIG_FILE not found, creating..."
    cat << EOF > "$TALLYMAN_CONFIG_FILE"
[exclude]
directories = [
]
EOF
    _cleanup_config_created="true"
    echo "$TALLYMAN_CONFIG_FILE created successfully"
  fi
}

# tallyman_report() - Main report generation logic
# Arguments:
#   $1 - Target directory to analyze (defaults to current directory)
# 
# Flow:
#   1. Validate target directory exists
#   2. Change to target directory
#   3. Verify it's a git repository
#   4. Install dependencies and create config
#   5. Generate report in reports/ subdirectory
#   6. Cleanup runs automatically via trap
tallyman_report() {
  local target_dir="${1:-.}"
  local original_dir
  original_dir="$(pwd)"
  
  # Set up cleanup trap and variables
  _cleanup_original_dir="$original_dir"
  trap cleanup EXIT

  # Check if directory exists
  if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' not found"
    exit 1
  fi

  echo "Generating report..."

  # Change to target directory if specified
  if [ "$target_dir" != "." ]; then
    if ! cd "$target_dir"; then
      echo "Error: Failed to change to directory '$target_dir'"
      exit 1
    fi
  fi

  # Check if it's a git repository (after cd to handle all cases correctly)
  if [ ! -d ".git" ]; then
    echo "Error: '$target_dir' is not a git repository"
    exit 1
  fi

  echo "Git repository detected at: $(pwd)"

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

  echo "Report generated successfully: ${original_dir}/${REPORTS_DIR}/${repo_name}_${repo_branch}_report.md"
}

# main() - Entry point
# Parses command line arguments and initiates report generation
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
