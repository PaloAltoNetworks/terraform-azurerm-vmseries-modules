#!/bin/bash

set -o pipefail
set -e

COMMAND=$1

case $1 in
  init)
    echo "::  INITIALIZING TERRAFORM  ::"
    terraform init | nl -bn
    echo
    ;;

  validate)
    echo "::  INITIALIZING TERRAFORM  ::"
    terraform init -backend=false | nl -bn
    echo
    echo "::  VALIDATING CODE  ::"
    terraform validate | nl -bn
    echo
    ;;

  plan)
    echo "::  PLANNING INFRASTRUCTURE  ::"
    terraform plan -var-file=ghci.tfvars | nl -bn
    echo
    ;;

  apply)
    echo "::  APPLYING INFRASTRUCTURE  ::"
    terraform apply -auto-approve -var-file=ghci.tfvars | nl -bn
    echo
    ;;

  idempotence)
    echo "::  TESTING IDEMPOTENCE  ::"
    terraform plan -detailed-exitcode -var-file=ghci.tfvars | nl -bn
    echo
    ;;

  test)  
    echo "::  DOWNLOADING GO DEPENDENCIES  ::"
    go get -v -t -d | nl -bn && go mod tidy | nl -bn
    echo
    echo "::  EXECUTING TERRATEST  ::"
    go test -v -timeout 120m -count=1 | nl -bn
    echo
    ;;

  destroy)
    echo "::  DESTROYING INFRASTRUCTURE  ::"
    terraform destroy -auto-approve -var-file=ghci.tfvars  | nl -bn
    ;;

  *)
    echo "ERROR: wrong param passed:: [$1]"
    exit 1

esac
