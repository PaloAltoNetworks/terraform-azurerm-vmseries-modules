> [!WARNING]
> This repository is now considered archived, and all future development will take place at our new location. For more details see https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/issues/236

> [!IMPORTANT]
> #### New Modules
> - GitHub - https://github.com/PaloAltoNetworks/terraform-azurerm-swfw-modules
> - Terraform Registry - https://registry.terraform.io/modules/PaloAltoNetworks/swfw-modules/azurerm/latest

![GitHub release (latest by date)](https://img.shields.io/github/v/release/PaloAltoNetworks/terraform-azurerm-vmseries-modules?style=flat-square)
![GitHub](https://img.shields.io/github/license/PaloAltoNetworks/terraform-modules-vmseries-ci-workflows?style=flat-square)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/PaloAltoNetworks/terraform-azurerm-vmseries-modules/release_ci.yml?style=flat-square)
![GitHub issues](https://img.shields.io/github/issues/PaloAltoNetworks/terraform-azurerm-vmseries-modules?style=flat-square)
![GitHub pull requests](https://img.shields.io/github/issues-pr/PaloAltoNetworks/terraform-azurerm-vmseries-modules?style=flat-square)
![Terraform registry downloads total](https://img.shields.io/badge/dynamic/json?color=green&label=downloads%20total&query=data.attributes.total&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2FPaloAltoNetworks%2Fvmseries-modules%2Fazurerm%2Fdownloads%2Fsummary&style=flat-square)
![Terraform registry download month](https://img.shields.io/badge/dynamic/json?color=green&label=downloads%20this%20month&query=data.attributes.month&url=https%3A%2F%2Fregistry.terraform.io%2Fv2%2Fmodules%2FPaloAltoNetworks%2Fvmseries-modules%2Fazurerm%2Fdownloads%2Fsummary&style=flat-square)

# Terraform Modules for Palo Alto Networks VM-Series on Azure Cloud

## Overview

A set of modules for using **Palo Alto Networks VM-Series firewalls** to provide control and protection
to your applications running on Azure Cloud. It deploys VM-Series as virtual machines and it configures
aspects such as virtual networks, subnets, network security groups, storage accounts, service principals,
Panorama virtual machine instances, and more.

The design is heavily based on the [Reference Architecture Guide for Azure](https://pandocs.tech/fw/115p-prime).

For copyright and license see the LICENSE file.

## Structure

This repository has the following directory structure:

* `modules` - this directory contains several standalone, reusable, production-grade Terraform modules. Each module is individually documented.
* `examples` - this directory shows examples of different ways to combine the modules contained in the
  `modules` directory. \
  Notice, **this code should NOT be used directly in production**. It might contain examples of sensitive data that normally should not be kept in a repository.

## Security

Please keep in mind that modules hosted in this repository require sensitive data to work, like: passwords, firewall bootstrap options, etc. We do not provide a mechanism to safely store this information. It's up to you to make sure this data is safely kept.

Examples provided here are a form of documentation - they should help you understand how to use the modules. They were not written with security in mind. They are here to demonstrate how to utilize code available in this repository and sometimes it's not possible to do it w/o providing variables or data that normally (in production) would not be kept in a VCS.

So before you use this code for something different than training please keep in mind to follow all Terraform and your organization's security best practices.

## Compatibility

The compatibility with Terraform is defined individually per each module. In general, expect the earliest compatible
Terraform version to be 1.0.0 across most of the modules.

## Versioning

These modules follow the principles of [Semantic Versioning](http://semver.org/). You can find each new release,
along with the changelog, on the GitHub [Releases](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/releases) page.

## Getting Help

If you have found a bug, please report it. The preferred way is to create a new issue on the [GitHub issue page](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/issues).

For consulting support, please contact services-sales@paloaltonetworks.com or your Palo Alto Networks account manager.

## Contributing

Contributions are welcome, and they are greatly appreciated! Every little bit helps,
and credit will always be given. Please follow our [contributing guide](https://github.com/PaloAltoNetworks/terraform-best-practices/blob/main/CONTRIBUTING.md).

<!-- ## Who maintains these modules?

This repository is maintained by [Palo Alto Networks](https://www.paloaltonetworks.com/).
If you're looking for commercial support or services, send an email to [address not known yet]. -->
