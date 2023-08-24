.phony: invalidate
invalidate:

%: invalidate %/main.tf
	@cd $@ && \
	echo "::group::DOWNLOADING GO DEPENDENCIES" && \
	go get -v -t -d  && \
	go mod tidy && \
	echo "::endgroup::" && \
	echo "::group::ACTION >>$(ACTION)<<" && \
	go test -run $(ACTION) -timeout 60m -count=1 && \
	echo "::endgroup::"
