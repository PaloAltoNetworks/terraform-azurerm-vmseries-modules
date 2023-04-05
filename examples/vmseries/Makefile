init:
	@../../makefile.sh init

prep_vars: check_uuid
	@../../makefile.sh prep_vars

validate:
	@../../makefile.sh validate

plan: check_uuid init
	@../../makefile.sh plan '${TF_PARAMS}'

plan_file: check_uuid init
	@../../makefile.sh plan_file '${TF_PARAMS}'

apply_file:
	@../../makefile.sh apply_file

apply: check_uuid init plan_file apply_file

idempotence: check_uuid
	@../../makefile.sh idempotence '${TF_PARAMS}'

destroy: check_uuid
	@../../makefile.sh destroy '${TF_PARAMS}'

delete_rg: check_uuid
	@../../makefile.sh delete_rg '${PREFIX}${RG}'

check_uuid:
ifndef UUID
	$(info Missing UUID, generate one for yourself using command:)
	$(info export UUID=$$(uuidgen | tr '[:upper:]' '[:lower:]'))
	$(error )
else
RG := $(shell echo ${UUID} | cut -d '-' -f 1,5)
PREFIX := ghci$(shell echo ${UUID} | cut -d '-' -f 2)-
TF_PARAMS := -var-file=example.tfvars -var resource_group_name=${RG} -var name_prefix=${PREFIX}
endif