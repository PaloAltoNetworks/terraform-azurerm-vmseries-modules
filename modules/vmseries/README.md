# Palo Alto Networks VM-Series Module for Azure

A Terraform module for deploying a VM-Series firewall in Azure cloud.
The module is not intended for use with Scale Sets.

## Usage

```hcl
module "vmseries" {
  source  = "../../modules/vmseries"

  location                      = "Australia Central"
  name                          = "my-firewall"
  password                      = "change-me-XOX0"
  bootstrap_storage_account     = module.vm-bootstrap.bootstrap_storage_account
  bootstrap_share_name          = "sharename"
  subnet_mgmt                   = module.networks.subnet_mgmt
  interfaces = [
    {
      subnet              = module.networks.subnet_public
      enable_backend_pool = false
    },
    {
      subnet              = module.networks.subnet_private
      enable_backend_pool = false
    },
  ]
}
```

## Accept Azure Marketplace Terms

Accept the Azure Marketplace terms for the VM-Series images. In a typical situation use these commands:

```sh
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan byol --subscription MySubscription
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan bundle1 --subscription MySubscription
az vm image terms accept --publisher paloaltonetworks --offer vmseries-flex --plan bundle2 --subscription MySubscription
```

You can revoke the acceptance later with the `az vm image terms cancel` command.
The acceptance applies to the entirety of your Azure Subscription.

## Caveat

The module only supports Azure regions that have more than one fault domain - as of 2021, the only two regions impacted
are `SouthCentralUSSTG` and `CentralUSEUAP`. The reason is that the module uses Availability Sets with Managed Disks.

[Instruction to re-check regions](https://docs.microsoft.com/en-us/azure/virtual-machines/manage-availability#use-managed-disks-for-vms-in-an-availability-set).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.12.29, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>2.26 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking"></a> [accelerated\_networking](#input\_accelerated\_networking) | Enable Azure accelerated networking (SR-IOV) for all network interfaces except the primary one (it is the PAN-OS management interface, which [does not support](https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-new-features/virtualization-features/support-for-azure-accelerated-networking-sriov) acceleration). | `bool` | `true` | no |
| <a name="input_avset_id"></a> [avset\_id](#input\_avset\_id) | The identifier of the Availability Set to use. Conflicts with `avzone`. | `string` | `null` | no |
| <a name="input_avzone"></a> [avzone](#input\_avzone) | The availability zone to use. Conflicts with `avset_id`. Example: `1` | `string` | `null` | no |
| <a name="input_bootstrap_share_name"></a> [bootstrap\_share\_name](#input\_bootstrap\_share\_name) | Azure File Share holding the bootstrap data. Should reside on `bootstrap_storage_account`. Bootstrapping is omitted if `bootstrap_share_name` is left at null. | `string` | `null` | no |
| <a name="input_bootstrap_storage_account"></a> [bootstrap\_storage\_account](#input\_bootstrap\_storage\_account) | Existing storage account object for bootstrapping and for holding small-sized boot diagnostics. Usually the object is passed from a bootstrap module's output. | `any` | `null` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | Absolute ID of your own Custom Image to be used for creating new VM-Series. If set, the `username`, `password`, `img_version`, `img_publisher`, `img_offer`, `img_sku` inputs are all ignored (these are used only for published images, not custom ones). The Custom Image is expected to contain PAN-OS software. | `string` | `null` | no |
| <a name="input_enable_plan"></a> [enable\_plan](#input\_enable\_plan) | Enable usage of the Offer/Plan on Azure Marketplace. Even plan sku "byol", which means "bring your own license", still requires accepting on the Marketplace (as of 2021). Can be set to `false` when using a custom image. | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_ids). | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine#identity_type). | `string` | `"SystemAssigned"` | no |
| <a name="input_img_offer"></a> [img\_offer](#input\_img\_offer) | The Azure Offer identifier corresponding to a published image. For `img_version` 9.1.1 or above, use "vmseries-flex"; for 9.1.0 or below use "vmseries1". | `string` | `"vmseries-flex"` | no |
| <a name="input_img_publisher"></a> [img\_publisher](#input\_img\_publisher) | The Azure Publisher identifier for a image which should be deployed. | `string` | `"paloaltonetworks"` | no |
| <a name="input_img_sku"></a> [img\_sku](#input\_img\_sku) | VM-series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks` | `string` | `"bundle2"` | no |
| <a name="input_img_version"></a> [img\_version](#input\_img\_version) | VM-series PAN-OS version - list available for a default `img_offer` with `az vm image list -o table --publisher paloaltonetworks --offer vmseries-flex --all` | `string` | `"9.1.3"` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | List of the network interface specifications.<br>The first should be the Management network interface, which does not participate in data filtering.<br>The remaining ones are the dataplane interfaces.<br><br>- `subnet_id`: Identifier of the existing subnet to use.<br>- `lb_backend_pool_id`: Identifier of the existing backend pool of the load balancer to associate.<br>- `enable_backend_pool`: If false, ignore `lb_backend_pool_id`. Default it false.<br>- `public_ip_address_id`: Identifier of the existing public IP to associate.<br><br>Example:<pre>[<br>  {<br>    subnet_id            = azurerm_subnet.my_mgmt_subnet.id<br>    public_ip_address_id = azurerm_public_ip.my_mgmt_ip.id<br>  },<br>  {<br>    subnet_id           = azurerm_subnet.my_pub_subnet.id<br>    lb_backend_pool_id  = module.inbound_lb.backend_pool_id<br>    enable_backend_pool = true<br>  },<br>]</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region where to deploy VM-Series and dependencies. | `string` | n/a | yes |
| <a name="input_managed_disk_type"></a> [managed\_disk\_type](#input\_managed\_disk\_type) | Type of Managed Disk which should be created. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_metrics_retention_in_days"></a> [metrics\_retention\_in\_days](#input\_metrics\_retention\_in\_days) | Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Defaults to 90. A special value 0 disables creation of Application Insights altogether. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Hostname of the VM-Series virtual machine. | `string` | `"fw00"` | no |
| <a name="input_name_application_insights"></a> [name\_application\_insights](#input\_name\_application\_insights) | Name of the Applications Insights instance to be created. Can be `null`, in which case a default name is auto-generated. | `string` | `null` | no |
| <a name="input_password"></a> [password](#input\_password) | Initial administrative password to use for VM-Series. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group name for VM-Series. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be associated with the resources created. | `map` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Initial administrative username to use for VM-Series. | `string` | `"panadmin"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size (type) to be created. Consult the *VM-Series Deployment Guide* as only a few selected sizes are supported. | `string` | `"Standard_D3_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_interfaces"></a> [interfaces](#output\_interfaces) | List of VM-Series network interfaces. The elements of the list are `azurerm_network_interface` objects. The order is the same as `interfaces` input. |
| <a name="output_metrics_instrumentation_key"></a> [metrics\_instrumentation\_key](#output\_metrics\_instrumentation\_key) | The Instrumentation Key of the created instance of Azure Application Insights. The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure. |
| <a name="output_mgmt_ip_address"></a> [mgmt\_ip\_address](#output\_mgmt\_ip\_address) | VM-Series management IP address. If `create_public_ip` was `true`, it is a public IP address, otherwise a private IP address. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The oid of Azure Service Principal of the created VM-Series. Usable only if `identity_type` contains SystemAssigned. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Custom Metrics

**(Optional)** Firewalls can publish custom metrics (for example `panSessionUtilization`) to Azure Application Insights.
This however requires a manual initialization: copy the output `metrics_instrumentation_key` and paste it into your
PAN-OS webUI -> Device -> VM-Series -> Azure. The module automatically completes the Step 1 of the
[official procedure](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall.html).

The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split to obtain
back a result for solely a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report
their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.
