# Palo Alto Networks VNet Module Example

>Azure Virtual Network (VNet) is the fundamental building block for your private network in Azure. VNet enables many types of Azure resources, such as Azure Virtual Machines (VM), to securely communicate with each other, the internet, and on-premises networks. VNet is similar to a traditional network that you'd operate in your own data center, but brings with it additional benefits of Azure's infrastructure such as scale, availability, and isolation.

This folder shows an example of Terraform code that uses the [Palo Alto Networks VNet module](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/tree/develop/modules/vnet) to deploy a single Virtual Network and a number of network components associated within the VNet in Azure. 

The following resources will be deployed when using the provided example:
* 1 [Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group).
* 1 [VNet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview).
* 3 [Subnets](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet). Every `Subnet` is associated with a `Network Security Group`.
* 3 [Network Security Groups](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview), from which 2 of them are associated with the defined [Network Security Rules](https://docs.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview#security-rules).
* 3 [Route Tables](https://docs.microsoft.com/en-us/azure/virtual-network/manage-route-table), from which 2 of them are associated with the defined [Route](https://docs.microsoft.com/en-us/azure/virtual-network/manage-route-table#create-a-route).

## Quick Start

Terraform automatically loads all files in the current directory with the exact name `terraform.tfvars` or matching `*.auto.tfvars`. In our example, Terraform will use the `example.auto.tfvars` file to populate the configuration with the example variable values. If you wish to use different variable values, create a new `*.tfvars` and use it with the `-var-file` when running Terraform commands.

1. Install [Terraform](https://www.terraform.io/). The Terraform version required to run this module can be checked [here](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/develop/modules/vnet/versions.tf).
1. `git clone` this repository to your computer, navigate into:

    >/terraform-azurerm-vmseries-modules/examples/vnet

1. Run `terraform init` to initialize the working directory.
1. Run `terraform plan` and verify the execution plan.
1. Run `terraform apply` to apply the changes required to reach the desired state of the configuration specified for this example.
