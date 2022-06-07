# Load Balancer Module for Azure

A Terraform module for deploying a Load Balancer for VM-Series firewalls. Supports both standalone and scale set deployments. Supports either inbound or outbound configuration.

The module creates a single load balancer and a single backend for it, but it allows multiple frontends.

## Usage

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound_lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/loadbalancer"

  resource_group_name = ""
  location            = ""
  name                = ""
  probe_name          = ""
  backend_name        = ""
  frontend_ips = {
    # Map of maps (each object has one frontend to many backend relationship) 
    pip-existing = {
      create_public_ip     = false
      public_ip_address_id = ""
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
        }
      }
    }
  }
}

# Deploy the outbound load balancer for traffic into the azure environment
module "outbound_lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/loadbalancer"
  
  resource_group_name = ""
  location            = ""
  name                = ""
  probe_name          = ""
  backend_name        = ""
  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address            = "10.0.1.6" 
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
        }
      }
    }
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.29, < 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.lb_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.lb_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_network_security_rule.allow_inbound_ips](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.exists](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avzones"></a> [avzones](#input\_avzones) | After provider version 3.x you need to specify in which availability zone(s) you want to place IP.<br>ie: for zone-redundant with 3 availability zone in current region value will be:<pre>["1","2","3"]</pre> | `list(string)` | `[]` | no |
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | The name of the backend pool to create. If an empty name is provided, it will be auto-generated.<br>All the frontends of the load balancer always use the same single backend. | `string` | `""` | no |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If false, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_frontend_ips"></a> [frontend\_ips](#input\_frontend\_ips) | A map of objects describing LB frontend IP configurations. Used for both public or private load balancers. <br>Keys of the map are the names of the created load balancers.<br><br>Public LB<br><br>- `create_public_ip` : Optional. Set to `true` to create a public IP.<br>- `public_ip_name` : Ignored if `create_public_ip` is `true`. The existing public IP resource name to use.<br>- `public_ip_resource_group` : Ignored if `create_public_ip` is `true` or if `public_ip_name` is null. The name of the resource group which holds `public_ip_name`.<br><br>Example<pre>frontend_ips = {<br>  pip_existing = {<br>    create_public_ip         = false<br>    public_ip_name           = "my_ip"<br>    public_ip_resource_group = "my_rg_name"<br>    rules = {<br>      HTTP = {<br>        port         = 80<br>        protocol     = "Tcp"<br>      }<br>    }<br>  }<br>}</pre>Private LB<br><br>- `subnet_id` : Identifier of an existing subnet.<br>- `private_ip_address_allocation` : Type of private allocation: `Static` or `Dynamic`.<br>- `private_ip_address` : If `Static`, the private IP address.<br><br>Example<pre>frontend_ips = {<br>  internal_fe = {<br>    subnet_id                     = azurerm_subnet.this.id<br>    private_ip_address_allocation = "Static"<br>    private_ip_address            = "192.168.0.10"<br>    rules = {<br>      HA_PORTS = {<br>        port         = 0<br>        protocol     = "All"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy load balancer and dependencies. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the load balancer. | `string` | n/a | yes |
| <a name="input_network_security_allow_source_ips"></a> [network\_security\_allow\_source\_ips](#input\_network\_security\_allow\_source\_ips) | List of IP CIDR ranges (such as `["192.168.0.0/16"]` or `["*"]`) from which the inbound traffic to all frontends should be allowed.<br>If it's empty, user is responsible for configuring a Network Security Group separately, possibly using the `frontend_combined_rules` output.<br>The list cannot include Azure tags like "Internet" or "Sql.EastUS". | `list(string)` | `[]` | no |
| <a name="input_network_security_base_priority"></a> [network\_security\_base\_priority](#input\_network\_security\_base\_priority) | The base number from which the auto-generated priorities of the NSG rules grow.<br>Ignored if `network_security_group_name` is empty or if `network_security_allow_source_ips` is empty. | `number` | `1000` | no |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | Name of the pre-existing Network Security Group (NSG) where to add auto-generated rules, each of which allows traffic through one rule of a frontend of this load balancer.<br>User is responsible to associate the NSG with the load balancer's subnet, the module only supplies the rules.<br>If empty, user is responsible for configuring an NSG separately, possibly using the `frontend_combined_rules` output. | `string` | `null` | no |
| <a name="input_network_security_resource_group_name"></a> [network\_security\_resource\_group\_name](#input\_network\_security\_resource\_group\_name) | Name of the Resource Group where the `network_security_group_name` resides. If empty, defaults to `resource_group_name`. | `string` | `""` | no |
| <a name="input_probe_name"></a> [probe\_name](#input\_probe\_name) | The name of the load balancer probe. | `string` | `""` | no |
| <a name="input_probe_port"></a> [probe\_port](#input\_probe\_port) | Health check port number of the load balancer probe. | `string` | `"80"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of a pre-existing Resource Group to place the resources in. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags to apply to the created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_pool_id"></a> [backend\_pool\_id](#output\_backend\_pool\_id) | The identifier of the backend pool. |
| <a name="output_frontend_combined_rules"></a> [frontend\_combined\_rules](#output\_frontend\_combined\_rules) | Map of all rules of all load balancer's frontends combined.<br>The map entries are intended to be easily convertible into NSG rules, hence each entry<br>contains `port`, `protocol`,  `frontend_ip`, and numerical sequential `index`.<br>The `frontend_ip` is the same as returned by output `frontend_ip_configs`.<br><br>Full example:<pre>{<br>  "frontend01-balancessh" = {<br>    fipkey       = "frontend01"<br>    frontend_ip  = "34.34.34.34"<br>    hash16       = 45991<br>    index        = 0<br>    nsg_priority = null<br>    port         = 22<br>    protocol     = "tcp"<br>    rulekey      = "balancessh"<br>  }<br>}</pre> |
| <a name="output_frontend_ip_configs"></a> [frontend\_ip\_configs](#output\_frontend\_ip\_configs) | Map of IP addresses, one per each entry of `frontend_ips` input. Contains public IP address for the frontends that have it, private IP address otherwise. |
| <a name="output_health_probe"></a> [health\_probe](#output\_health\_probe) | The health probe object. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
