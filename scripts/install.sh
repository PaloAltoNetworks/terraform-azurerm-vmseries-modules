#!/usr/bin/bash

# install.sh - prepare the dependencies for the run.sh
# 
# It only handles installing from scratch and will probably fail on a subsequent run.
# It overuses the &&, &, and backslash line continuation so it could be easily converted
# into a Dockerfile, just by adding `RUN` directives (and `COPY requirements.txt .`).

set -euo pipefail

cd "$(dirname $0)"

curl -sL https://github.com/terraform-docs/terraform-docs/releases/download/v0.12.1/terraform-docs-v0.12.1-linux-amd64 > terraform-docs    & \
curl -sL https://github.com/tfsec/tfsec/releases/download/v0.34.0/tfsec-linux-amd64 > tfsec    & \
curl -sL https://github.com/terraform-linters/tflint/releases/download/v0.20.3/tflint_linux_amd64.zip > tflint.zip    & \
curl -sL https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip > terraform-0.12.29.zip    & \
curl -sL https://releases.hashicorp.com/terraform/0.13.7/terraform_0.13.7_linux_amd64.zip > terraform-0.13.7.zip    & \
curl -sL https://releases.hashicorp.com/terraform/0.14.9/terraform_0.14.9_linux_amd64.zip > terraform-0.14.9.zip    & \
wait
echo Finished successfully all parallel downloads ------------------------------------------------------------------

chmod +x terraform-docs
mv terraform-docs /usr/local/bin/
chmod +x tfsec
mv tfsec /usr/local/bin/

unzip tflint.zip
rm tflint.zip
mv tflint /usr/local/bin/

unzip terraform-0.12.29.zip
rm terraform-0.12.29.zip
mv terraform /usr/local/bin/terraform

unzip terraform-0.13.7.zip
rm terraform-0.13.7.zip
mv terraform /usr/local/bin/terraform-0.13.7

unzip terraform-0.14.9.zip
rm terraform-0.14.9.zip
mv terraform /usr/local/bin/terraform-0.14.9

git --version
terraform-docs --version
tfsec --version
tflint --version
terraform version

echo "Also, the newest release: $(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64")"
echo "Also, the newest release: $(curl -s https://api.github.com/repos/tfsec/tfsec/releases/latest | grep -o -E "https://.+?tfsec-linux-amd64")"
echo "Also, the newest release: $(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")"

python3 -m pip install -r requirements.txt
