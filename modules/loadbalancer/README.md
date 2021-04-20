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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, <0.14 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>2.42 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>2.42 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.lb_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.lb_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.exists](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | The name of the backend pool to create. If an empty name is provided, it will be auto-generated. All the frontends of the load balancer always use the same single backend. | `string` | `""` | no |
| <a name="input_frontend_ips"></a> [frontend\_ips](#input\_frontend\_ips) | A map of objects describing LB frontend IP configurations. Used for both public or private load balancers. <br>Keys of the map are the names of the created load balancers.<br>### Public loadbalancer:<br>- `create_public_ip` : Set to `true` to create a public IP, otherwise use a pre-existing public IP.<br>- `public_ip_name` : Ignored if `create_public_ip` is `true`. The existing public IP resource name to use.<br>- `public_ip_resource_group` : Ignored if `create_public_ip` is `true`. The existing public IP resource group name.<br>#### Private loadbalancer:<br>- `subnet_id` : ID of an existing subnet.<br>- `private_ip_address_allocation` : Type of private allocation: `Static` or `Dynamic`.<br>- `private_ip_address` : If Static, the private IP address.<br>Example:<pre># Public load balancer example<br>frontend_ips = {<br>  pip-existing = {<br>    create_public_ip         = false<br>    public_ip_name           = "my_ip"<br>    public_ip_resource_group = "my_rg"<br>    rules = {<br>      HTTP = {<br>        port         = 80<br>        protocol     = "Tcp"<br>      }<br>    }<br>  }<br>}<br><br># Private load balancer example<br>frontend_ips = {<br>  internal_fe = {<br>    subnet_id                     = ""<br>    private_ip_address_allocation = "Static"<br>    private_ip_address            = "192.168.0.10"<br>    rules = {<br>      HA_PORTS = {<br>        port         = 0<br>        protocol     = "All"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy load balancer and dependencies. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the load balancer. | `string` | n/a | yes |
| <a name="input_probe_name"></a> [probe\_name](#input\_probe\_name) | The name of the load balancer probe. | `string` | `""` | no |
| <a name="input_probe_port"></a> [probe\_port](#input\_probe\_port) | Health check port number of the load balancer probe. | `string` | `"80"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of a pre-existing Resource Group to place the resources in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_pool_id"></a> [backend\_pool\_id](#output\_backend\_pool\_id) | The identifier of the backend pool. |
| <a name="output_frontend_ip_configs"></a> [frontend\_ip\_configs](#output\_frontend\_ip\_configs) | The Frontend configs of the loadbalancer. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
