<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks VM-Series Module for Azure

A Terraform module for deploying a VM-Series firewall in Azure cloud.
The module is not intended for use with Scale Sets.

## Usage

For usage please refer to any reference architecture example.

## Accept Azure Marketplace Terms

Accept the Azure Marketplace terms for the VM-Series images. In a typical situation use these commands:

```sh
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol --subscription MySubscription
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan bundle1 --subscription MySubscription
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan bundle2 --subscription MySubscription
```

You can revoke the acceptance later with the `az vm image terms cancel` command.
The acceptance applies to the entirety of your Azure Subscription.

## Caveat Regarding Region

By default, the VM-Series is placed into an Availability Zone "1". Hence, it can only deploy
successfully in the [Regions that support Zones](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).
If your Region doesn't, use an alternative mechanism of Availability Set, which is inferior but universally supported:

```hcl
   avset_id = azurerm_availability_set.this.id
   avzone   = null
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | The name of the Azure Virtual Machine.
[`resource_group_name`](#resource_group_name) | `string` | The name of the Resource Group to use.
[`location`](#location) | `string` | The name of the Azure region to deploy the resources in.
[`authentication`](#authentication) | `object` | A map defining authentication settings (including username and password).
[`image`](#image) | `object` | Basic Azure VM configuration.
[`virtual_machine`](#virtual_machine) | `object` | Firewall parameters configuration.
[`interfaces`](#interfaces) | `list` | List of the network interface specifications.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | The map of tags to assign to all created resources.



## Module's Outputs

Name |  Description
--- | ---
`mgmt_ip_address` | VM-Series management IP address. If `create_public_ip` was `true`, it is a public IP address, otherwise a private IP address.
`interfaces` | Map of VM-Series network interfaces. Keys are equal to var.interfaces `name` properties.
`principal_id` | The ID of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.5, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `linux_virtual_machine` (managed)
- `network_interface` (managed)
- `network_interface_backend_address_pool_association` (managed)
- `public_ip` (managed)
- `public_ip` (data)

## Inputs/Outpus details

### Required Inputs


#### name

The name of the Azure Virtual Machine.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

The name of the Resource Group to use.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

The name of the Azure region to deploy the resources in.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>


#### authentication

A map defining authentication settings (including username and password).

Following properties are available:

- `username`                        - (`string`, optional, defaults to `panadmin`) the initial administrative VMseries username
- `password`                        - (`string`, optional, defaults to `null`) the initial administrative VMSeries password
- `disable_password_authentication` - (`bool`, optional, defaults to `true`) disables password-based authentication
- `ssh_keys`                        - (`list`, optional, defaults to `[]`) a list of initial administrative SSH public keys

> [!Important]
> The `password` property is required when `ssh_keys` is not specified.

> [!Important]
> `ssh_keys` property is a list of strings, so each item should be the actual public key value.
> If you would like to load them from files use the `file` function, for example: `[ file("/path/to/public/keys/key_1.pub") ]`.



Type: 

```hcl
object({
    username                        = optional(string, "panadmin")
    password                        = optional(string)
    disable_password_authentication = optional(bool, true)
    ssh_keys                        = optional(list(string), [])
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### image

Basic Azure VM configuration.

Following properties are available:

- `version`             - (`string`, optional, defaults to `null`) VMSeries PAN-OS version; list available with 
                          `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all`
- `publisher`           - (`string`, optional, defaults to `paloaltonetworks`) the Azure Publisher identifier for a image
                          which should be deployed
- `offer`               - (`string`, optional, defaults to `vmseries-flex`) the Azure Offer identifier corresponding to a
                          published image
- `sku`                 - (`string`, optional, defaults to `byol`) VMSeries SKU; list available with
                          `az vm image list -o table --all --publisher paloaltonetworks`
- `enable_marketplace_plan` - (`bool`, optional, defaults to `true`) when set to `true` accepts the license for an offer/plan
                              on Azure Market Place
- `custom_id`         - (`string`, optional, defaults to `null`) absolute ID of your own custom PanOS image to be used for
                              creating new Virtual Machines

> [!Important]
> `custom_id` and `version` properties are mutually exclusive.


Type: 

```hcl
object({
    version                 = optional(string)
    publisher               = optional(string, "paloaltonetworks")
    offer                   = optional(string, "vmseries-flex")
    sku                     = optional(string, "byol")
    enable_marketplace_plan = optional(bool, true)
    custom_id               = optional(string)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### virtual_machine

Firewall parameters configuration.

This map contains basic, as well as some optional Firewall parameters. Both types contain sane defaults.
Nevertheless they should be at least reviewed to meet deployment requirements.

List of either required or important properties: 

- `size`              - (`string`, optional, defaults to `Standard_D3_v2`) Azure VM size (type). Consult the *VM-Series
                        Deployment Guide* as only a few selected sizes are supported
- `zone`              - (`number`, ??????????) Availability Zone to place the VM in, `null` value means a non-zonal deployment
                        this Firewall will be created, explicit `null` means non-zonal deployment
- `disk_type`         - (`string`, optional, defaults to `StandardSSD_LRS`) type of Managed Disk which should be created,
                        possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS` (works only for selected
                        `vm_size` values)
- `disk_name`         - (`string`, optional, defaults to VM name + `-disk` suffix) name od the OS disk
- `bootstrap_options` - bootstrap options to pass to VM-Series instance.

    Proper syntax is a string of semicolon separated properties, for example:

    ```hcl
    bootstrap_options = "type=dhcp-client;panorama-server=1.2.3.4"
    ```

    For more details on bootstrapping [see documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/init-cfgtxt-file-components).

List of other, optional properties: 

- `avset_key`                      - (`string`, optional, default to `null) identifier of the Availability Set to use
- `accelerated_networking`        - (`bool`, optional, defaults to `true`) when set to `true`  enables Azure accelerated
                                    networking (SR-IOV) for all dataplane network interfaces, this does not affect the
                                    management interface (always disabled)
- `disk_encryption_set_id`        - (`string`, optional, defaults to `null`) the ID of the Disk Encryption Set which should be
                                    used to encrypt this VM's disk
- `encryption_at_host_enabled`    - (`bool`, optional, defaults to Azure defaults) should all of disks be encrypted
                                    by enabling Encryption at Host
- `diagnostics_storage_uri`       - (`string`, optional, defaults to `null`) storage account's blob endpoint to hold
                                    diagnostic files
- `identity_type`                 - (`string`, optional, defaults to `SystemAssigned`) type of Managed Service Identity that
                                    should be configured on this VM. Can be one of "SystemAssigned", "UserAssigned" or
                                    "SystemAssigned, UserAssigned".
- `identity_ids`                  - (`list`, optional, defaults to `[]`) a list of User Assigned Managed Identity IDs to be 
                                    assigned to this VM. Required only if `identity_type` is not "SystemAssigned"
- `allow_extension_operations`    - (`bool`, optional, defaults to `false`) should Extension Operations be allowed on this VM



Type: 

```hcl
object({
    size                       = optional(string, "Standard_D3_v2")
    bootstrap_options          = optional(string)
    zone                       = string
    disk_type                  = optional(string, "StandardSSD_LRS")
    disk_name                  = string
    avset_id                   = optional(string)
    accelerated_networking     = optional(bool, true)
    encryption_at_host_enabled = optional(bool)
    disk_encryption_set_id     = optional(string)
    diagnostics_storage_uri    = optional(string)
    identity_type              = optional(string, "SystemAssigned")
    identity_ids               = optional(list(string), [])
    allow_extension_operations = optional(bool, false)
  })
```


<sup>[back to list](#modules-required-inputs)</sup>

#### interfaces

List of the network interface specifications.

> [!Note]
> The ORDER in which you specify the interfaces DOES MATTER.

Interfaces will be attached to VM in the order you define here, therefore:

- The first should be the management interface, which does not participate in data filtering.
- The remaining ones are the dataplane interfaces.
  
Following configuration options are available:

- `name`                      - (`string`, required) the interface name
- `subnet_id`                 - (`string`, required) ID of an existing subnet to create the interface in
- `private_ip_address`        - (`string`, optional, defaults to `null`) static private IP to assign to the interface. When
                                skipped Azure will assign one dynamically. Keep in mind that a dynamic IP is guarantied not to
                                change as long as the VM is running. Any stop/deallocate/restart operation might cause the IP to
                                change.
- `create_public_ip`          - (`bool`, optional, defaults to `false`) if `true`, creates a public IP for the interface
- `public_ip_name`            - (`string`, optional, defaults to `null`) name of the public IP to associate with the interface.
                                When `create_public_ip` is set to `true` this will become a name of a newly created Public IP
                                interface. Otherwise this is a name of an existing interfaces that will be sourced and attached
                                to the interface.
- `public_ip_resource_group_name`  - (`string`, optional, defaults to `var.resource_group_name`) name of a Resource Group that
                                contains public IP that that will be associated with the interface. Used only when 
                                `create_public_ip` is `false`.
- `attach_to_lb_backend_pool` - (`bool`, optional, defaults to `false`) set to `true` if you would like to associate this
                                interface with a Load Balancer backend pool.
- `lb_backend_pool_id`        - (`string`, optional, defaults to `null`) ID of an existing backend pool to associate the
                                interface with.

Example:

```hcl
[
  # management interface with a new public IP
  {
    name                 = "fw-mgmt"
    subnet_id            = azurerm_subnet.my_mgmt_subnet.id
    public_ip_name       = "fw-mgmt-pip"
    create_public_ip     = true
  },
  # public interface reusing an existing public IP resource
  {
    name                      = "fw-public"
    subnet_id                 = azurerm_subnet.my_pub_subnet.id
    attach_to_lb_backend_pool = true
    lb_backend_pool_id        = module.inbound_lb.backend_pool_id
    create_public_ip          = false
    public_ip_name            = "fw-public-pip"
  },
]
```



Type: 

```hcl
list(object({
    name                          = string
    subnet_id                     = string
    create_public_ip              = optional(bool, false)
    public_ip_name                = optional(string)
    public_ip_resource_group_name = optional(string)
    private_ip_address            = optional(string)
    lb_backend_pool_id            = optional(string)
    attach_to_lb_backend_pool     = optional(bool, false)
  }))
```


<sup>[back to list](#modules-required-inputs)</sup>



### Optional Inputs





#### tags

The map of tags to assign to all created resources.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>






<!-- END_TF_DOCS -->