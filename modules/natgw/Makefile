init_go:
	@echo "::group::DOWNLOADING GO DEPENDENCIES" && \
	go get -v -t -d  && \
	go mod tidy && \
	echo "::endgroup::"

validate: init_go
	@echo "::group::VALIDATING CODE" && \
	go test -run Validate -timeout 120s -count=1 && \
	echo "::endgroup::"

test:
	@echo "::group::TESTING INFRASTRUCTURE" && \
	echo "PLACEHOLDER" && \
	echo "::endgroup::"
