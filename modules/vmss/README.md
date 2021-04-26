# Palo Alto Networks VMSS Module for Azure

A terraform module for VMSS VM-Series firewalls in Azure.

## Usage

```hcl
module "vmss" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vmss"

  location                  = "Australia Central"
  name_prefix               = "pan"
  password                  = "your-password"
  subnet_mgmt               = azurerm_subnet.subnet_mgmt
  subnet_private            = azurerm_subnet.subnet_private
  subnet_public             = module.networks.subnet_public
  bootstrap_storage_account = module.panorama.bootstrap_storage_account
  bootstrap_share_name      = "inboundsharename"
  vhd_container             = "vhd-storage-container-id"
  lb_backend_pool_id        = "private-backend-pool-id"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.15 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=2.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.vmss](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking"></a> [accelerated\_networking](#input\_accelerated\_networking) | If true, enable Azure accelerated networking (SR-IOV) for all dataplane network interfaces. [Requires](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) PAN-OS 9.0 or higher. The PAN-OS management interface (nic0) is never accelerated, whether this variable is true or false. | `bool` | `true` | no |
| <a name="input_bootstrap_share_name"></a> [bootstrap\_share\_name](#input\_bootstrap\_share\_name) | File share for bootstrap config | `any` | n/a | yes |
| <a name="input_bootstrap_storage_account"></a> [bootstrap\_storage\_account](#input\_bootstrap\_storage\_account) | Storage account setup for bootstrapping | `any` | n/a | yes |
| <a name="input_img_sku"></a> [img\_sku](#input\_img\_sku) | VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_img_version"></a> [img\_version](#input\_img\_version) | VM-series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"9.0.4"` | no |
| <a name="input_lb_backend_pool_id"></a> [lb\_backend\_pool\_id](#input\_lb\_backend\_pool\_id) | ID Of inbound load balancer backend pool to associate with the VM series firewall | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to install VM Series Scale sets and dependencies. | `any` | n/a | yes |
| <a name="input_name_domain_name_label"></a> [name\_domain\_name\_label](#input\_name\_domain\_name\_label) | n/a | `string` | `"inbound-vm-mgmt"` | no |
| <a name="input_name_fw"></a> [name\_fw](#input\_name\_fw) | n/a | `string` | `"inbound-fw"` | no |
| <a name="input_name_fw_mgmt_pip"></a> [name\_fw\_mgmt\_pip](#input\_name\_fw\_mgmt\_pip) | n/a | `string` | `"inbound-fw-mgmt-pip"` | no |
| <a name="input_name_mgmt_nic_ip"></a> [name\_mgmt\_nic\_ip](#input\_name\_mgmt\_nic\_ip) | n/a | `string` | `"inbound-nic-fw-mgmt"` | no |
| <a name="input_name_mgmt_nic_profile"></a> [name\_mgmt\_nic\_profile](#input\_name\_mgmt\_nic\_profile) | n/a | `string` | `"inbound-nic-fw-mgmt-profile"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to add to all the object names here | `any` | n/a | yes |
| <a name="input_name_private_nic_ip"></a> [name\_private\_nic\_ip](#input\_name\_private\_nic\_ip) | n/a | `string` | `"inbound-nic-fw-private"` | no |
| <a name="input_name_private_nic_profile"></a> [name\_private\_nic\_profile](#input\_name\_private\_nic\_profile) | n/a | `string` | `"inbound-nic-fw-private-profile"` | no |
| <a name="input_name_public_nic_ip"></a> [name\_public\_nic\_ip](#input\_name\_public\_nic\_ip) | n/a | `string` | `"inbound-nic-fw-public"` | no |
| <a name="input_name_public_nic_profile"></a> [name\_public\_nic\_profile](#input\_name\_public\_nic\_profile) | n/a | `string` | `"inbound-nic-fw-public-profile"` | no |
| <a name="input_name_rg"></a> [name\_rg](#input\_name\_rg) | n/a | `string` | `"vmseries-rg"` | no |
| <a name="input_name_scale_set"></a> [name\_scale\_set](#input\_name\_scale\_set) | n/a | `string` | `"inbound-scaleset"` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for VM-Series. | `string` | n/a | yes |
| <a name="input_sep"></a> [sep](#input\_sep) | Seperator | `string` | `"-"` | no |
| <a name="input_subnet_mgmt"></a> [subnet\_mgmt](#input\_subnet\_mgmt) | Management subnet. | `any` | n/a | yes |
| <a name="input_subnet_private"></a> [subnet\_private](#input\_subnet\_private) | internal/private subnet | `any` | n/a | yes |
| <a name="input_subnet_public"></a> [subnet\_public](#input\_subnet\_public) | External/public subnet | `any` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for VM-Series. | `string` | `"panadmin"` | no |
| <a name="input_vhd_container"></a> [vhd\_container](#input\_vhd\_container) | Storage container for storing VMSS instance VHDs. | `any` | n/a | yes |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Minimum instances per scale set. | `number` | `2` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inbound-scale-set-name"></a> [inbound-scale-set-name](#output\_inbound-scale-set-name) | Name of inbound scale set. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
