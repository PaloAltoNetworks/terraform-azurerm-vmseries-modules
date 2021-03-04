Palo Alto Networks Panorama Module for Azure
===========

A terraform module for deploying a working Panorama instance in Azure.

Usage
-----

```hcl
module "panorama" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/panorama"

  panorama_name       = var.panorama_name
  name_prefix         = var.name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location //Optional; if not provided, will use Resource Group location
  avzone              = var.avzone   // Optional Availability Zone number

  interfaces = {
    public = {
      subnet_id            = module.vnet.vnet_subnets[0]
      private_ip_address   = "10.0.0.6" // Optional: If not set, use dynamic allocation
      public_ip            = "true"    // (optional|bool, default: "false")
      enable_ip_forwarding = "false"  // (optional|bool, default: "false")
      primary_interface    = "true"
    }
    mgmt = {
      subnet_id            = module.vnet.vnet_subnets[1]
      private_ip_address   = "10.0.1.6" // Optional: If not set, use dynamic allocation
      public_ip            = "false"   // (optional|bool, default: "false")
      enable_ip_forwarding = "false"  // (optional|bool, default: "false")
    }
  }

  logging_disks = {
    disk_name_1 = {
      size : "50"
      zone : "1"
      lun : "1"
    }
    disk_name_2 = {
      dize : "50"
      zone : "2"
      lun : "2"
    }
  }

  panorama_size    = var.panorama_size
  custom_image_id  = var.custom_image_id             // optional
  username         = var.username                    // no default - this can't be admin anymore (add this in documentation)
  password         = random_password.password.result // no default - check the complexity required by Azure marketplace (add this in documentation)
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
| terraform | >=0.13, <0.14 |
| azurerm | ~>2.42 |
| random | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~>2.42 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| avzone | Optional Availability Zone number. | `any` | `null` | no |
| boot\_diagnostic\_storage\_uri | Existing diagnostic storage uri | `any` | `null` | no |
| custom\_image\_id | n/a | `string` | `null` | no |
| enable\_plan | Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image. | `bool` | `true` | no |
| interfaces | A map of objects describing the intefaces configuration. Keys of the map are the names and values are { subnet\_id, private\_ip\_address, public\_ip, enable\_ip\_forwarding }. Example:<pre>{<br>  public = {<br>    subnet_id            = module.vnet.vnet_subnets[0]<br>    private_ip_address   = "10.0.0.6" // Optional: If not set, use dynamic allocation<br>    public_ip            = "true"    // (optional|bool, default: "false")<br>    enable_ip_forwarding = "false"  // (optional|bool, default: "false")<br>    primary_interface    = "true"<br>  }<br>  mgmt = {<br>    subnet_id            = module.vnet.vnet_subnets[1]<br>    private_ip_address   = "10.0.1.6" // Optional: If not set, use dynamic allocation<br>    public_ip            = "false"   // (optional|bool, default: "false")<br>    enable_ip_forwarding = "false"  // (optional|bool, default: "false")<br>  }<br>}</pre> | `map(any)` | n/a | yes |
| location | Region to deploy panorama into. | `string` | `""` | no |
| logging\_disks | A map of objects describing the additional disk configuration. The keys of the map are the names and values are { size, zones, lun }. <br> The size value is provided in GB. The recommended size for additional(optional) disks should be at least 2TB (2048 GB). Example:<pre>{<br>  disk_name_1 = {<br>    size: "50"<br>    zone: "1"<br>    lun: "1"<br>  }<br>  disk_name_2 = {<br>    size: "50"<br>    zone: "2"<br>    lun: "2"<br>  }<br>}</pre> | `map(any)` | `{}` | no |
| name\_panorama\_pip | The name for public ip allows distinguish from other type of public ips. | `string` | `"panorama-pip"` | no |
| name\_prefix | Prefix to add to all the object names here. | `any` | n/a | yes |
| panorama\_name | The Panorama common name. | `string` | `"panorama"` | no |
| panorama\_offer | Panorama offer. | `string` | `"panorama"` | no |
| panorama\_publisher | Panorama Publisher. | `string` | `"paloaltonetworks"` | no |
| panorama\_size | Virtual Machine size. | `string` | `"Standard_D5_v2"` | no |
| panorama\_sku | Panorama SKU. | `string` | `"byol"` | no |
| panorama\_version | Panorama PAN-OS Software version. List published images with `az vm image list -o table --all --publisher paloaltonetworks --offer panorama` | `string` | `"10.0.3"` | no |
| password | Initial administrative password to use for Panorama. | `string` | n/a | yes |
| resource\_group\_name | The resource group name created for Panorama. | `string` | n/a | yes |
| sep | Separator used in the names of the generated resources. May be empty. | `string` | `"-"` | no |
| tags | A map of tags to be associated with the resources created. | `map(any)` | `{}` | no |
| username | Initial administrative username to use for Panorama. | `string` | `"panadmin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| panorama-publicips | Panorama Public IP addresses |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
