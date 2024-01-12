<!-- BEGIN_TF_DOCS -->
---
short\_title: Standalone Panorama Deployment
type: example
show\_in\_hub: true
---
# Standalone Panorama Deployment

Panorama is a centralized management system that provides global visibility and control over multiple Palo Alto Networks Next
Generation Firewalls through an easy to use web-based interface. Panorama enables administrators to view aggregate or
device-specific application, user, and content data and manage multiple Palo Alto Networks firewalls — all from a central
location.

The Terraform code presented here will deploy Palo Alto Networks Panorama management platform in Azure in management only mode
(without additional logging disks). For option on how to add additional logging disks - please refer to panorama
[module documentation](../../modules/panorama/README.md#input\_logging\_disks).

## Topology

This is a non zonal deployment. The deployed infrastructure consists of:

- a VNET containing:
  - one subnet dedicated to host Panorama appliances
  - a Network Security Group to give access to Panorama's public interface
- a Panorama appliance with a public IP assigned to the management interface

![standalone-panorama](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/assets/2110772/a2394f73-c0a8-4878-8693-825356abbd23)

## Prerequisites

A list of requirements might vary depending on the platform used to deploy the infrastructure but a minimum one includes:

- (in case of non cloud shell deployment) credentials and (optionally) tools required to authenticate against Azure Cloud, see
  [AzureRM provider documentation for details](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure)
- [supported](#requirements) version of [`Terraform`](<https://developer.hashicorp.com/terraform/downloads>)
- if you have not run Palo Alto Networks Panorama images in a subscription it might be necessary to accept the license first
  ([see this note](../../modules/panorama/README.md#accept-azure-marketplace-terms))

**Note!**

- after the deployment Panorama remains not licensed and not configured.
- keep in mind that **this code** is **only an example**. It's main purpose is to introduce the Terraform modules.

## Usage

### Deployment Steps

- checkout the code locally (if you haven't done so yet)
- copy the [`example.tfvars`](./example.tfvars) file, rename it to `terraform.tfvars` and adjust it to your needs (take a closer
  look at the `TODO` markers)
- (optional) authenticate to AzureRM, switch to the Subscription of your choice if necessary
- initialize the Terraform module:

  ```bash
  terraform init
  ```

- (optional) plan you infrastructure to see what will be actually deployed:

  ```bash
  terraform plan
  ```

- deploy the infrastructure (you will have to confirm it with typing in `yes`):

  ```bash
  terraform apply
  ```

  The deployment takes couple of minutes. Observe the output. At the end you should see a summary similar to this:

  ```console
  Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

  Outputs:

  panorama_mgmt_ips = {
    "pn-1" = "1.2.3.4"
  }
  password = <sensitive>
  username = "panadmin"
  ```

- at this stage you have to wait couple of minutes for the Panorama to bootstrap.

### Post deploy

Panorama in this example is configured with password authentication. To retrieve the initial credentials run:

- for username:

  ```bash
  terraform output username
  ```

- for password:

  ```bash
  terraform output password
  ```

The management public IP addresses are available in the `panorama_mgmt_ips`:

```bash
terraform output panorama_mgmt_ips
```

You can now login to the devices using either:

- cli - ssh client is required
- Web UI (https) - any modern web browser, note that initially the traffic is encrypted with a self-signed certificate.

You can now proceed with licensing and configuring the devices.

### Cleanup

To remove the deployed infrastructure run:

```bash
terraform destroy
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`location`](#location) | `string` | The Azure region to use.
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group.
[`vnets`](#vnets) | `map` | A map defining VNETs.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | Map of tags to assign to the created resources.
[`name_prefix`](#name_prefix) | `string` | A prefix that will be added to all created resources.
[`create_resource_group`](#create_resource_group) | `bool` | When set to `true` it will cause a Resource Group creation.
[`enable_zones`](#enable_zones) | `bool` | If `true`, enable zone support for resources.
[`availability_sets`](#availability_sets) | `map` | A map defining availability sets.
[`panoramas`](#panoramas) | `map` | A map defining Azure Virtual Machine based on Palo Alto Networks Panorama image.



## Module's Outputs

Name |  Description
--- | ---
`username` | Initial administrative username to use for VM-Series.
`password` | Initial administrative password to use for VM-Series.
`panorama_mgmt_ips` | 

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0


Providers used in this module:

- `random`
- `azurerm`


Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---
`vnet` | - | ../../modules/vnet | Manage the network required for the topology.
`panorama` | - | ../../modules/panorama | 


Resources used in this module:

- `availability_set` (managed)
- `resource_group` (managed)
- `password` (managed)
- `resource_group` (data)

## Inputs/Outpus details

### Required Inputs



#### location

The Azure region to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>



#### resource_group_name

Name of the Resource Group.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>


#### vnets

A map defining VNETs.
  
For detailed documentation on each property refer to [module documentation](../../modules/vnet/README.md)

- `create_virtual_network`  - (`bool`, optional, defaults to `true`) when set to `true` will create a VNET, 
                              `false` will source an existing VNET.
- `name`                    - (`string`, required) a name of a VNET. In case `create_virtual_network = false` this should be
                              a full resource name, including prefixes.
- `address_space`           - (`list(string)`, required when `create_virtual_network = false`) a list of CIDRs for a newly
                              created VNET
- `resource_group_name`     - (`string`, optional, defaults to current RG) a name of an existing Resource Group in which
                              the VNET will reside or is sourced from
- `create_subnets`          - (`bool`, optional, defaults to `true`) if `true`, create Subnets inside the Virtual Network,
                              otherwise use source existing subnets
- `subnets`                 - (`map`, optional) map of Subnets to create or source, for details see
                              [VNET module documentation](../../modules/vnet/README.md#subnets)
- `network_security_groups` - (`map`, optional) map of Network Security Groups to create, for details see
                              [VNET module documentation](../../modules/vnet/README.md#network_security_groups)
- `route_tables`            - (`map`, optional) map of Route Tables to create, for details see
                              [VNET module documentation](../../modules/vnet/README.md#route_tables)


Type: 

```hcl
map(object({
    name                   = string
    resource_group_name    = optional(string)
    create_virtual_network = optional(bool, true)
    address_space          = optional(list(string))
    network_security_groups = optional(map(object({
      name                          = string
      disable_bgp_route_propagation = optional(bool)
      rules = optional(map(object({
        name                         = string
        priority                     = number
        direction                    = string
        access                       = string
        protocol                     = string
        source_port_range            = optional(string)
        source_port_ranges           = optional(list(string))
        destination_port_range       = optional(string)
        destination_port_ranges      = optional(list(string))
        source_address_prefix        = optional(string)
        source_address_prefixes      = optional(list(string))
        destination_address_prefix   = optional(string)
        destination_address_prefixes = optional(list(string))
      })), {})
    })), {})
    route_tables = optional(map(object({
      name = string
      routes = map(object({
        name                = string
        address_prefix      = string
        next_hop_type       = string
        next_hop_ip_address = optional(string)
      }))
    })), {})
    create_subnets = optional(bool, true)
    subnets = optional(map(object({
      name                            = string
      address_prefixes                = optional(list(string), [])
      network_security_group_key      = optional(string)
      route_table_key                 = optional(string)
      enable_storage_service_endpoint = optional(bool, false)
    })), {})
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>





### Optional Inputs


#### tags

Map of tags to assign to the created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### name_prefix

A prefix that will be added to all created resources.
There is no default delimiter applied between the prefix and the resource name. Please include the delimiter in the actual prefix.

Example:
```
name_prefix = "test-"
```
  
**Note!** \
This prefix is not applied to existing resources. If you plan to reuse i.e. a VNET please specify it's full name, even if it is also prefixed with the same value as the one in this property.


Type: string

Default value: ``

<sup>[back to list](#modules-optional-inputs)</sup>

#### create_resource_group

When set to `true` it will cause a Resource Group creation. Name of the newly specified RG is controlled by `resource_group_name`.
When set to `false` the `resource_group_name` parameter is used to specify a name of an existing Resource Group.


Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>


#### enable_zones

If `true`, enable zone support for resources.

Type: bool

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>


#### availability_sets

A map defining availability sets. Can be used to provide infrastructure high availability when zones cannot be used.

Following properties are supported:
- `name` - name of the Application Insights.
- `update_domain_count` - specifies the number of update domains that are used, defaults to 5 (Azure defaults).
- `fault_domain_count` - specifies the number of fault domains that are used, defaults to 3 (Azure defaults).

Please keep in mind that Azure defaults are not working for each region (especially small ones, w/o any Availability Zones).
Please verify how many update and fault domains are supported in a region before deploying this resource.


Type: 

```hcl
map(object({
    name                = string
    update_domain_count = optional(number, 5)
    fault_domain_count  = optional(number, 3)
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### panoramas

A map defining Azure Virtual Machine based on Palo Alto Networks Panorama image.
  
For details and defaults for available options please refer to the [`panorama`](../../modules/panorama/README.md) module.

The basic Panorama VM configuration properties are as follows:

- `name`            - (`string`, required) name of the VM, will be prefixed with the value of `var.name_prefix`.
- `authentication`  - (`map`, optional, defaults to example defaults) authentication settings for the deployed VM.

    The `authentication` property is optional and holds the firewall admin access details. By default, standard username
    `panadmin` will be set and a random password will be auto-generated for you (available in Terraform outputs).

    **Note!** \
    The `disable_password_authentication` property is by default `false` in this example. When using this value, you don't have
    to specify anything but you can still additionally pass SSH keys for authentication. You can however set this property to 
    `true`, then you have to specify `ssh_keys` property.

    For all properties and their default values see [module's documentation](../../modules/panorama/README.md#authentication).

- `image`           - (`map`, required) properties defining a base image used by the deployed VM.

    The `image` property is required but there are only 2 properties (mutually exclusive) that have to be set, either:

    - `version`   - (`string`) describes the PAN-OS image version from Azure Marketplace.
    - `custom_id` - (`string`) absolute ID of your own custom PAN-OS image.

    For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#image).

- `virtual_machine` - (`map`, optional, defaults to module defaults) a map that groups most common VM configuration options.

    Following properties are available:

    - `vnet_key`  - (`string`, required) a key of a VNET defined in `var.vnets`. This is the VNET that hosts subnets used to
                    deploy network interfaces for deployed VM.
    - `size`      - (`string`, optional, defaults to module defaults) Azure VM size (type). Consult the *VM-Series Deployment
                    Guide* as only a few selected sizes are supported.
    - `zone`      - (`string`, optional, defaults to module defaults) the Availability Zone in which the VM will be created.
    - `disk_type` - (`string`, optional, defaults to module defaults) type of a Managed Disk which should be created, possible
                    values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected `size` values).
      
    For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#virtual_machine).

- `interfaces`      - (`list`, required) configuration of all network interfaces, order does matter - the 1<sup>st</sup>
                      interface should be the management one. 
                        
    Following properties are available:

    - `name`             - (`string`, required) name of the network interface (will be prefixed with `var.name_prefix`).
    - `subnet_key`       - (`string`, required) a key of a subnet to which the interface will be assigned as defined in
                           `var.vnets`.
    - `create_public_ip` - (`bool`, optional, defaults to module defaults) create a Public IP for an interface.

    For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#interfaces).

- `logging_disks`   - (`map`, optional, defaults to `null`) configuration of additional data disks for Panorama logs. 
  
    Following properties are available:

    - `name` - (`string`, required) the Managed Disk name.
    - `lun`  - (`string`, required) the Logical Unit Number of the Data Disk, which needs to be unique within the VM.

    For details on the other properties refer to [module's documentation](../../modules/panorama/README.md#logging_disks).


Type: 

```hcl
map(object({
    name = string
    authentication = object({
      username                        = optional(string, "panadmin")
      password                        = optional(string)
      disable_password_authentication = optional(bool, false)
      ssh_keys                        = optional(list(string), [])
    })
    image = object({
      version                 = optional(string)
      publisher               = optional(string)
      offer                   = optional(string)
      sku                     = optional(string)
      enable_marketplace_plan = optional(bool)
      custom_id               = optional(string)
    })
    virtual_machine = object({
      vnet_key                   = string
      size                       = optional(string)
      zone                       = string
      disk_type                  = optional(string)
      disk_name                  = optional(string)
      avset_key                  = optional(string)
      encryption_at_host_enabled = optional(bool)
      disk_encryption_set_id     = optional(string)
      diagnostics_storage_uri    = optional(string)
      identity_type              = optional(string)
      identity_ids               = optional(list(string))
    })
    interfaces = list(object({
      name                          = string
      subnet_key                    = string
      private_ip_address            = optional(string)
      create_public_ip              = optional(bool, false)
      public_ip_name                = optional(string)
      public_ip_resource_group_name = optional(string)
    }))
    logging_disks = optional(map(object({
      name      = string
      size      = optional(string)
      lun       = string
      disk_type = optional(string)
    })), {})
  }))
```


Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->