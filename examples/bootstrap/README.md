# Palo Alto Networks Bootstrap Module Example

This Terraform example uses the [Palo Alto Networks Bootstrap module](../../modules/bootstrap) to deploy a Storage Account and the dependencies required
to [bootstrap a VM-Series firewall in Azure](https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html#idd51f75b8-e579-44d6-a809-2fafcfe4b3b6).

The following resources will be deployed when using the provided example:
* 1 [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group).
* 1 [Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview).
* 1 [File Share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction#:~:text=Azure%20Files%20offers%20fully%20managed,cloud%20or%20on%2Dpremises%20deployments).

## Quick Start

1. Install [Terraform](https://www.terraform.io/). The Terraform version required to run this module can be checked [here](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/develop/modules/bootstrap/versions.tf).
1. `git clone` this repository to your computer, navigate into:

    >/terraform-azurerm-vmseries-modules/examples/bootstrap

1. Run `terraform init` to initialize the working directory.
1. Run `terraform plan -var-file=example.tfvars` and verify the execution plan.
1. Run `terraform apply -var-file=example.tfvars` to apply the changes required to reach the desired state of the configuration specified for this example.

__NOTE:__ As the file names suggests, the `init-cfg.sample.txt` and `authcodes.sample` are used only for demonstration purposes - if you wish to bootstrap your VM-Series firewall, you should modify the files content with proper data.
