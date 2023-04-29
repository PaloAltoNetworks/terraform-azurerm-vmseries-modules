#!/bin/bash

set -o pipefail

TFPLAN=gh_ci.tfplan

COMMAND=$1
TF_OPTIONS=${@: 2}

case $1 in
  init)
    set -e
    echo "::  INITIALIZING TERRAFORM  ::"
    terraform init | nl -bn
    echo
    set +e
    ;;

  validate)
    set -e
    echo "::  INITIALIZING TERRAFORM  ::"
    terraform init -backend=false | nl -bn
    echo
    echo "::  VALIDATING CODE  ::"
    terraform validate | nl -bn
    echo
    set +e
    ;;

  plan)
    set -e
    echo "::  PLANNING INFRASTRUCTURE  ::"
    terraform plan ${TF_OPTIONS} | nl -bn
    echo
    set +e
    ;;

  plan_file)
    set -e
    echo "::  CREATING INFRASTRUCTURE PLAN FILE  ::"
    terraform plan ${TF_OPTIONS} -out ${TFPLAN} | nl -bn
    echo
    set +e
    ;;

  apply_file)
    echo "::  APPLYING INFRASTRUCTURE PLAN FILE  ::"
    for INDEX in {1..3}; do
      terraform apply ${TFPLAN} | nl -bn
      TF_FAILED=$?
      if [ $TF_FAILED -eq 0 ]; then
        break
      else
        TF_FAILED=1
      fi
      sleep 5
    done

    if [ $TF_FAILED -ne 0 -a "$GITHUB_ACTIONS" ]; then
      touch APPLY
    fi
    echo
    ;;

  idempotence)
    echo "::  TESTING IDEMPOTENCE  ::"
    terraform plan -detailed-exitcode ${TF_OPTIONS} | nl -bn
    if [ $? -ne 0 -a "$GITHUB_ACTIONS" ]; then
        touch IDEMPOTENCE
    fi
    echo
    ;;

  destroy)
    echo "::  DESTROYING INFRASTRUCTURE  ::"
    TF_FAILED=0

    # for Azure, due to API bugs, we try to run destroy maximum 3 times
    for INDEX in {1..3}; do
      terraform destroy -auto-approve ${TF_OPTIONS}  | nl -bn
      TF_FAILED=$?
      if [ $TF_FAILED -eq 0 ]; then
        if [ -f "${TFPLAN}" ]; then
          echo "::  REMOVING INFRASTRUCTURE PLAN FILE  ::"
          rm ${TFPLAN} | nl -bn
        fi
        echo
        break
      else
        TF_FAILED=1
      fi
      sleep 5
    done

    if [ $TF_FAILED -ne 0 -a "$GITHUB_ACTIONS" ]; then
      touch DESTROY
    fi
    ;;

  delete_rg)
    echo "::  DELETING INFRASTRUCTURE  ::"
    TF_PARAMS=${@: 2}
    set -e
    for G in ${TF_PARAMS[@]}; do
      az group delete -g "$G" -y --no-wait | nl -bn
    done
    echo
    set +e
    ;;
  *)
    echo "ERROR: wrong param passed:: [$1]"
    exit 1

esac