ifndef UUID
UUID := $(shell uuidgen | tr '[:upper:]' '[:lower:]')
endif
RG := $(shell echo ${UUID} | cut -d '-' -f 1,5)
PREFIX := ghci$(shell echo ${UUID} | cut -d '-' -f 2)-
TF_PARAMS := -var-file=example.tfvars -var resource_group_name=${RG} -var name_prefix=${PREFIX}

init: 
	@../../makefile.sh init

validate:
	@../../makefile.sh validate

plan: init
	../../makefile.sh plan '${TF_PARAMS}'

plan_file: init
	@../../makefile.sh plan_file '${TF_PARAMS}'

apply_file:
	@../../makefile.sh apply_file

apply: init plan_file apply_file

indepotency:
	@../../makefile.sh indepotency '${TF_PARAMS}'

destroy:
	@../../makefile.sh destroy '${PREFIX}${RG}'
