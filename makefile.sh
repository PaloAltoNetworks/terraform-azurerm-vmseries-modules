#!/bin/bash

set -o pipefail
set -e

TFPLAN=gh_ci.tfplan

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
    TF_PARAMS=${@: 2}
    terraform plan ${TF_PARAMS} | nl -bn
    echo
    ;;

  plan_file)
    echo "::  CREATING INFRASTRUCTURE PLAN FILE  ::"
    TF_PARAMS=${@: 2}
    terraform plan ${TF_PARAMS} -out ${TFPLAN} | nl -bn
    echo
    ;;

  apply_file)
    echo "::  APPLYING INFRASTRUCTURE PLAN FILE  ::"
    if [ -f "${TFPLAN}" ]; then
      terraform apply ${TFPLAN} | nl -bn
    else
      echo "No TFPLAN file."
      exit 1
    fi
    echo
    ;;

  indepotency)
    echo "::  TESTING INDEPOTENCY  ::"
    TF_PARAMS=${@: 2}
    terraform plan -detailed-exitcode ${TF_PARAMS} | nl -bn
    echo
    ;;

  destroy)
    echo "::  DESTROYING INFRASTRUCTURE  ::"
    TF_PARAMS=${@: 2}
    for G in ${TF_PARAMS[@]}; do az group delete -g "$G" -y --no-wait | nl -bn; done
    echo

    echo "::  REMOVING INFRASTRUCTURE PLAN FILE  ::"
    if [ -f "${TFPLAN}" ]; then rm ${TFPLAN} | nl -bn; fi
    echo
    ;;

esac
