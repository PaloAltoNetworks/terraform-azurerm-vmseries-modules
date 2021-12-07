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
  `modules` directory.

## Compatibility

The compatibility with Terraform is defined individually per each module. In general, expect the earliest compatible
Terraform version to be 0.12.29 across most of the modules.
<!-- [FUTURE] If you need to stay on Terraform 0.12.29 and need to use these modules, the recommended last compatible release is 1.2.3. -->

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
