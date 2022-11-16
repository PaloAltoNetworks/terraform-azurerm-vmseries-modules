ifndef UUID
UUID := $(shell uuidgen | tr '[:upper:]' '[:lower:]')
endif
RG := GHCI-$(shell echo ${UUID} | cut -d '-' -f 1,5)
STORAGE := ghci$(shell echo ${UUID} | cut -d '-' -f 5)
TF_PARAMS := -var-file=example.tfvars -var resource_group_name=${RG} -var files={"files/authcodes.sample"="license/authcodes","files/init-cfg.sample.txt"="config/init-cfg.txt"} -var storage_account_name=${STORAGE}

init: 
	@../../makefile.sh init

validate:
	@../../makefile.sh validate

plan: init
	@../../makefile.sh plan '${TF_PARAMS}'

plan_file: init
	@../../makefile.sh plan_file '${TF_PARAMS}'

apply_file:
	@../../makefile.sh apply_file

apply: init plan_file apply_file

indepotency:
	@../../makefile.sh indepotency '${TF_PARAMS}'

destroy:
	@../../makefile.sh destroy '${RG}'
