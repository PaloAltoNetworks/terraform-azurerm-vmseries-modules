.phony: all invalidate help

all:
	@echo "Run [make help] for usage details."

invalidate:

help:
	@echo "This Makefile is run by specifying a module path as a target name." ; \
	echo "It takes one argument: ACTION. Value of this argument is specific to a particular module." ; \
	echo "It represents the name of a Terratest test function." ; \
	echo "Typically this will be: Validate, Plan, Apply, Idempotence, but it should be verified with" ; \
	echo "  module's main_test.go file." ; \
	echo ; \
	echo "Example:" ; \
	echo "  make examples/common_vmseries ACTION=Plan" ; \
	echo

%: invalidate %/main.tf
	@cd $@ && \
	echo "::group::DOWNLOADING GO DEPENDENCIES" && \
	go get -v -t -d  && \
	go mod tidy && \
	echo "::endgroup::" && \
	echo "::group::ACTION >>$(ACTION)<<" && \
	go test -run $(ACTION) -timeout 60m -count=1 && \
	echo "::endgroup::"
