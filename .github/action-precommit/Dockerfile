# This Dockerfile defines the developer's environment for running all the tests.
FROM python:3.6-buster

RUN curl -sL https://github.com/terraform-docs/terraform-docs/releases/download/v0.12.1/terraform-docs-v0.12.1-linux-amd64 > terraform-docs    && \
    chmod +x terraform-docs    && \
    mv terraform-docs /usr/local/bin/    && \
    echo "Newest release: $(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64")"

RUN curl -sL https://github.com/terraform-linters/tflint/releases/download/v0.20.3/tflint_linux_amd64.zip > tflint.zip    && \
    unzip tflint.zip    && \
    rm tflint.zip    && \
    mv tflint /usr/local/bin/    && \
    echo "Newest release: $(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")"

RUN curl -sL https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip > terraform.zip    && \
    unzip terraform.zip    && \
    rm terraform.zip    && \
    cp -p terraform /usr/local/bin/terraform    && \
    mv terraform /usr/local/bin/tf-0.12.29    && \
    echo "Newest release of terraform: $(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep -o -E '"tag_name" *: *"[^"]*"')"

RUN git --version    && \
    terraform version    && \
    terraform-docs --version    && \
    tflint --version

RUN pip install pre-commit==2.7.1

CMD ["pre-commit", "run", "--all-files"]
