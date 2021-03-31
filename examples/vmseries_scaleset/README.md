# Palo Alto Networks VM-Series Scalset Module Example

>Virtual Machine Scale Sets (VMSS) — A VMSS is a group of individual virtual machines (VMs) within the Microsoft Azure public cloud that administrators can configure and manage as a single unit. The firewall templates provided for auto scaling, create and manage a group of identical, load balanced VM-Series firewalls that are scaled up or down based on custom metrics published by the firewalls to Azure Application Insights. The scaling-in and scaling out operation can be based on configurable thresholds.

This folder shows an example of Terraform code that helps to deploy an auto-scaling tier of VM-Series firewalls using Azure VMSS.

## Quick Start

1. Install [Terraform](https://www.terraform.io/). The Terraform version required to run this module can be checked [here](./versions.tf).
1. `git clone` this repository to your computer, navigate into:

    >/terraform-azurerm-vmseries-modules/examples/vnet

1. Run `terraform init` to initialize the working directory.
1. Run `terraform plan` and verify the execution plan.
1. Run `terraform apply` to apply the changes required to reach the desired state of the configuration specified for this example.
