# Palo Alto Networks Panorama Module for Azure

A terraform module for deploying a working Panorama instance in Azure.

## Usage

```hcl
module "panorama" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/panorama"

  panorama_name       = var.panorama_name
  name_prefix         = var.name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location //Optional; if not provided, will use Resource Group location
  avzone              = var.avzone   // Optional Availability Zone number

  interface = {                          // Only one interface in Panorama VM is supported
    mgmt = {
      subnet_id            = ""
      private_ip_address   = "10.0.0.6" // Optional: If not set, use dynamic allocation
      public_ip            = "true"    // (optional|bool, default: "false")
      enable_ip_forwarding = "false"  // (optional|bool, default: "false")
      primary_interface    = "true"
    }
  }

  logging_disks = {
    disk_name_1 = {
      size : "2048"
      zone : "1"
      lun : "1"
    }
    disk_name_2 = {
      dize : "4096"
      zone : "2"
      lun : "2"
    }
  }

  panorama_size    = var.panorama_size
  custom_image_id  = var.custom_image_id // optional
  username         = var.username        // required, no default
  password         = var.password        // required, no default
  panorama_sku     = var.panorama_sku
  panorama_version = var.panorama_version

  primary_interface = var.primary_interface

  tags = var.tags
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.42 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>2.42 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine.panorama](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avzone"></a> [avzone](#input\_avzone) | Optional Availability Zone number. | `any` | `null` | no |
| <a name="input_boot_diagnostic_storage_uri"></a> [boot\_diagnostic\_storage\_uri](#input\_boot\_diagnostic\_storage\_uri) | Existing diagnostic storage uri | `any` | `null` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | n/a | `string` | `null` | no |
| <a name="input_enable_plan"></a> [enable\_plan](#input\_enable\_plan) | Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image. | `bool` | `true` | no |
| <a name="input_interface"></a> [interface](#input\_interface) | A array of map describing the intefaces configuration. Keys of the map are the names and values are { subnet\_id, private\_ip\_address, public\_ip, enable\_ip\_forwarding }. Example:<pre>[<br>  {<br>    name                 = "mgmt"<br>    subnet_id            = ""<br>    private_ip_address   = ""<br>    public_ip            = "true"<br>    public_ip_name       = ""<br>    enable_ip_forwarding = "false"<br>  }<br>]</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy Panorama into. | `string` | n/a | yes |
| <a name="input_logging_disks"></a> [logging\_disks](#input\_logging\_disks) | A map of objects describing the additional disk configuration. The keys of the map are the names and values are { size, zones, lun }. <br> The size value is provided in GB. The recommended size for additional(optional) disks should be at least 2TB (2048 GB). Example:<pre>{<br>  disk_name_1 = {<br>    size: "2048"<br>    zone: "1"<br>    lun: "1"<br>  }<br>  disk_name_2 = {<br>    size: "2048"<br>    zone: "2"<br>    lun: "2"<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| <a name="input_os_disk_name"></a> [os\_disk\_name](#input\_os\_disk\_name) | The name of OS disk. The name is auto-generated when not provided. | `string` | `null` | no |
| <a name="input_panorama_name"></a> [panorama\_name](#input\_panorama\_name) | The Panorama common name. | `string` | `"panorama"` | no |
| <a name="input_panorama_offer"></a> [panorama\_offer](#input\_panorama\_offer) | Panorama offer. | `string` | `"panorama"` | no |
| <a name="input_panorama_publisher"></a> [panorama\_publisher](#input\_panorama\_publisher) | Panorama Publisher. | `string` | `"paloaltonetworks"` | no |
| <a name="input_panorama_size"></a> [panorama\_size](#input\_panorama\_size) | Virtual Machine size. | `string` | `"Standard_D5_v2"` | no |
| <a name="input_panorama_sku"></a> [panorama\_sku](#input\_panorama\_sku) | Panorama SKU. | `string` | `"byol"` | no |
| <a name="input_panorama_version"></a> [panorama\_version](#input\_panorama\_version) | Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama` | `string` | `"10.0.3"` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm). | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the existing resource group where to place all the resources created by this module. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources created. | `map(any)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for Panorama. Mind the [Azure-imposed restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-username-requirements-when-creating-a-vm). | `string` | `"panadmin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interface"></a> [interface](#output\_interface) | Panorama network interface. The `azurerm_network_interface` object. |
| <a name="output_mgmt_ip_address"></a> [mgmt\_ip\_address](#output\_mgmt\_ip\_address) | Panorama management IP address. If `public_ip` was `true`, it is a public IP address, otherwise a private IP address. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
