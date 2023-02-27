ifndef UUID
UUID := $(shell uuidgen | tr '[:upper:]' '[:lower:]')
endif
IN_RG := GHCI-$(shell echo ${UUID} | cut -d '-' -f 1,3)
OUT_RG := GHCI-$(shell echo ${UUID} | cut -d '-' -f 2,5)
STORAGE := ghci$(shell echo ${UUID} | cut -d '-' -f 5)
TF_PARAMS := -var-file=example.tfvars -var inbound_resource_group_name=${IN_RG} -var outbound_resource_group_name=${OUT_RG} -var inbound_files={"inbound_files/authcodes.sample"="license/authcodes","inbound_files/init-cfg.sample.txt"="config/init-cfg.txt"} -var outbound_files={"outbound_files/authcodes.sample"="license/authcodes","outbound_files/init-cfg.sample.txt"="config/init-cfg.txt"} -var storage_account_name=${STORAGE}

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
	@../../makefile.sh destroy '${IN_RG}' '${OUT_RG}'
