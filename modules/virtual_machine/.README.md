# Azure Virtual Machine Module for Azure

A Terraform module for deploying a virtual machine in Azure cloud. This module intended to be an internal module that can be leveraged during proof of concepts and demos.

You can easily control the linux flavour by passing `UbuntuServer`, `RHEL`, `openSUSE-Leap`, `CentOS`, `Debian`, `CoreOS` and `SLES` as the value to the `vm_os_simple` variable.


## Usage

```hcl
module "vm" {
  source  = "../../modules/virtual_machine"

  location            = "Australia East"
  resource_group_name = azurerm_resource_group.this.name
  name                = "linux-vm"
  vm_os_simple        = "UbuntuServer"
  username            = "foo"
  password            = "Change-Me-007"
  interfaces = [
    {
      name      = "my-mgmt-interface"
      subnet_id = lookup(module.vnet.subnet_ids, "subnet-mgmt", null)
    },
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.7, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.64 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking"></a> [accelerated\_networking](#input\_accelerated\_networking) | Enable Azure accelerated networking (SR-IOV) for all network interfaces | `bool` | `true` | no |
| <a name="input_avset_id"></a> [avset\_id](#input\_avset\_id) | The identifier of the Availability Set to use. When using this variable, set `avzone = null`. | `string` | `null` | no |
| <a name="input_avzone"></a> [avzone](#input\_avzone) | The availability zone to use, for example "1", "2", "3". Ignored if `enable_zones` is false. Conflicts with `avset_id`, in which case use `avzone = null`. | `string` | `"1"` | no |
| <a name="input_bootstrap_share_name"></a> [bootstrap\_share\_name](#input\_bootstrap\_share\_name) | Azure File Share holding the bootstrap data. Should reside on `bootstrap_storage_account`. Bootstrapping is omitted if `bootstrap_share_name` is left at null. | `string` | `null` | no |
| <a name="input_bootstrap_storage_account"></a> [bootstrap\_storage\_account](#input\_bootstrap\_storage\_account) | Existing storage account object for bootstrapping and for holding small-sized boot diagnostics. Usually the object is passed from a bootstrap module's output. | `any` | `null` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | Absolute ID of your own Custom Image to be used for creating a new virtual machine. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). | `string` | `null` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If false, the input `avzone` is ignored and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_ids). | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_type). | `string` | `"SystemAssigned"` | no |
| <a name="input_img_offer"></a> [img\_offer](#input\_img\_offer) | The Azure Offer identifier corresponding to a published image. | `string` | `null` | no |
| <a name="input_img_publisher"></a> [img\_publisher](#input\_img\_publisher) | The Azure Publisher identifier for a image which should be deployed. | `string` | `null` | no |
| <a name="input_img_sku"></a> [img\_sku](#input\_img\_sku) | Virtual machine image SKU - list available with `az vm image list -o table --all --publisher foo` | `string` | `null` | no |
| <a name="input_img_version"></a> [img\_version](#input\_img\_version) | Virtual machine image version - list available for a default `img_offer` with `az vm image list -o table --publisher foo --offer bar --all` | `string` | `null` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interface specifications.<br>The first should be the Management network interface, which does not participate in data filtering.<br>The remaining ones are the dataplane interfaces.<br><br>- `subnet_id`: Identifier of the existing subnet to use.<br>- `lb_backend_pool_id`: Identifier of the existing backend pool of the load balancer to associate.<br>- `enable_backend_pool`: If false, ignore `lb_backend_pool_id`. Default is false.<br>- `public_ip_address_id`: Identifier of the existing public IP to associate.<br>- `create_public_ip`: If true, create a public IP for the interface and ignore the `public_ip_address_id`. Default is false.<br><br>Example:<pre>[<br>  {<br>    subnet_id            = azurerm_subnet.my_mgmt_subnet.id<br>    public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id<br>  },<br>  {<br>    subnet_id           = azurerm_subnet.my_pub_subnet.id<br>    lb_backend_pool_id  = module.inbound_lb.backend_pool_id<br>    enable_backend_pool = true<br>  },<br>]</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region where to deploy and dependencies. | `string` | n/a | yes |
| <a name="input_managed_disk_type"></a> [managed\_disk\_type](#input\_managed\_disk\_type) | Type of OS Managed Disk to create for the virtual machine. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_name"></a> [name](#input\_name) | Hostname of the virtual machine. | `string` | `"fw00"` | no |
| <a name="input_os_disk_name"></a> [os\_disk\_name](#input\_os\_disk\_name) | Optional name of the OS disk to create for the virtual machine. If empty, the name is auto-generated. | `string` | `null` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for the virtual machine. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group where to place the resources created. | `string` | n/a | yes |
| <a name="input_standard_os"></a> [standard\_os](#input\_standard\_os) | Definition of the standard OS with "SimpleName" = "publisher,offer,sku" | `map` | <pre>{<br>  "CentOS": "OpenLogic,CentOS,7.6",<br>  "CoreOS": "CoreOS,CoreOS,Stable",<br>  "Debian": "credativ,Debian,9",<br>  "RHEL": "RedHat,RHEL,8.2",<br>  "SLES": "SUSE,SLES,12-SP2",<br>  "UbuntuServer": "Canonical,UbuntuServer,18.04-LTS",<br>  "openSUSE-Leap": "SUSE,openSUSE-Leap,15.1"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources created. | `map(any)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for the virtual machine. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | n/a | yes |
| <a name="input_vm_os_simple"></a> [vm\_os\_simple](#input\_vm\_os\_simple) | Allows user to specify a simple name for the OS required and auto populate the publisher, offer, sku parameters | `string` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size (type) to be created. | `string` | `"Standard_D3_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interfaces"></a> [interfaces](#output\_interfaces) | List of interfaces. The elements of the list are `azurerm_network_interface` objects. The order is the same as `interfaces` input. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The oid of Azure Service Principal of the created virtual machine. Usable only if `identity_type` contains SystemAssigned. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

