# Test Infrastructure code

Terraform code to deploy a test infrastructure consisting of:

* two VNETs that can be peered with the transit VNET deployed in any of the examples, each contains:
  * a Linux-based VM running NGINX server to mock a web application
  * an Azure Bastion (enables SSH access to the VM)
  * UDRs forcing the traffic to flow through the NVA deployed by any of NGFW examples.

## Usage

To use this code, please deploy one of the examples first. Then copy the [`examples.tfvars`](./example.tfvars) to `terraform.tfvars` and edit it to your needs.

Please correct the values marked with `TODO` markers at minimum.

## Reference
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
