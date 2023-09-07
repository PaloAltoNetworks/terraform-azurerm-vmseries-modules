init: 
	@../../makefile.sh init

prep_vars: check_uuid
	@if [ ! -f ghci.tfvars ]; then sed -E "s/example-/${PREFIX}/g;s/vmseriesgwlbboostrap/${STORAGE}/g;s/^resource_group_name.*/resource_group_name = \"${RG}\"/g" example.tfvars > ghci.tfvars; fi
	@if [ ! -f files/init-cfg.txt ]; then  cp files/init-cfg.txt.sample files/init-cfg.txt; fi

validate:
	@../../makefile.sh validate

plan: init prep_vars
	@../../makefile.sh plan

apply: init prep_vars
	@../../makefile.sh apply

idempotence:
	@../../makefile.sh idempotence

destroy:
	@../../makefile.sh destroy
	@rm ghci.tfvars

check_uuid:
ifndef UUID
	$(info Missing UUID, generate one for yourself using command:)
	$(info export UUID=$$(uuidgen | tr '[:upper:]' '[:lower:]'))
	$(error )
else
RG := $(shell echo ${UUID} | cut -d '-' -f 1,5)
PREFIX := ghci$(shell echo ${UUID} | cut -d '-' -f 2)-
STORAGE := $(shell echo ${UUID} | cut -d '-' -f 2,3,4 | tr -d '-')
endif