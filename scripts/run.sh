#!/usr/bin/bash

# run.sh - Run the usual pre-commit checks.

set -euo pipefail

pre-commit run --all-files terraform_fmt 
pre-commit run --all-files terraform_docs 
pre-commit run --all-files terraform_tflint
