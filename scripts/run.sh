#!/usr/bin/bash

# run.sh - Run the usual pre-commit checks.

set -euo pipefail

pre-commit run --all-files
