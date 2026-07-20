#!/usr/bin/env bash

set -Eeuo pipefail

PYLON_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="${PYLON_ROOT}/modules"

usage() {
  cat <<'HELP'
Usage:
  ./pylon.sh <module> <command> [arguments]

Modules:
  wireless     Alfa AWUS1900 interface management
  recon        Reconnaissance utilities
  web          Web-assessment utilities
  report       Reporting utilities
  system       System and dependency checks
  legacy       Run the preserved original script
  help         Show this help

Examples:
  sudo ./pylon.sh wireless audit
  sudo ./pylon.sh wireless listen
  sudo ./pylon.sh wireless loud
  sudo ./pylon.sh wireless toggle
  sudo ./pylon.sh legacy audit
HELP
}

run_module() {
  local script="$1"
  shift

  if [[ ! -x "$script" ]]; then
    printf 'PYLON error: module unavailable: %s\n' "$script" >&2
    exit 1
  fi

  exec "$script" "$@"
}

main() {
  local module="${1:-help}"
  shift || true

  case "$module" in
    wireless)
      run_module "${MODULE_DIR}/wireless/wireless.sh" "$@"
      ;;
    recon)
      run_module "${MODULE_DIR}/recon/recon.sh" "$@"
      ;;
    web)
      run_module "${MODULE_DIR}/web/web.sh" "$@"
      ;;
    report|reporting)
      run_module "${MODULE_DIR}/reporting/reporting.sh" "$@"
      ;;
    system|utilities)
      run_module "${MODULE_DIR}/utilities/utilities.sh" "$@"
      ;;
    legacy)
      run_module "${PYLON_ROOT}/scripts/pylon-legacy.sh" "$@"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      printf 'Unknown PYLON module: %s\n\n' "$module" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
