# Palo Alto Networks inbound/outbound Load Balancer Module for Azure

A terraform module for deploying an Inbound/Outbound Load Balancer for VM-Series firewalls. Supports both standalone and scale set deployments.

## Usage

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"

  resource_group_name = ""
  location            = ""
  name_probe          = ""
  name_lb             = ""
  frontend_ips = {
    # Map of maps (each object has one frontend to many backend relationship) 
    pip-existing = {
      create_public_ip     = false
      public_ip_address_id = ""
      rules = {
        HTTP = {
          port         = 80
          protocol     = "Tcp"
          backend_name = "backend1_name"
        }
      }
    }
  }
}

# Deploy the outbound load balancer for traffic into the azure environment
module "outbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"
  
  resource_group_name = ""
  location            = ""
  name_probe          = ""
  name_lb             = ""
  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address            = "10.0.1.6" 
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend3_name"
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
| terraform | >=0.13, <0.14 |
| azurerm | ~>2.42 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~>2.42 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| frontend\_ips | A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create\_public\_ip, public\_ip\_address\_id, rules }. Example:<pre># Deploy the inbound load balancer for traffic into the azure environment<br>module "inbound-lb" {<br>  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"<br><br>  resource_group_name = ""<br>  location            = ""<br>  name_probe          = ""<br>  name_lb             = ""<br>  frontend_ips = {<br>    # Map of maps (each object has one frontend to many backend relationship) <br>    pip-existing = {<br>      create_public_ip     = false<br>      public_ip_address_id = ""<br>      rules = {<br>        HTTP = {<br>          port         = 80<br>          protocol     = "Tcp"<br>          backend_name = "backend1_name"<br>        }<br>      }<br>    }<br>  }<br>}<br><br># Deploy the outbound load balancer for traffic into the azure environment<br>module "outbound-lb" {<br>  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"<br><br>  resource_group_name = ""<br>  location            = ""<br>  name_probe          = ""<br>  name_lb             = ""<br>  frontend_ips = {<br>    internal_fe = {<br>      subnet_id                     = ""<br>      private_ip_address_allocation = "Static" // Dynamic or Static<br>      private_ip_address = "" <br>      rules = {<br>        HA_PORTS = {<br>          port         = 0<br>          protocol     = "All"<br>          backend_name = "backend3_name"<br>        }<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| location | Region to deploy load balancer and dependencies. | `string` | `""` | no |
| name\_lb | The loadbalancer name. | `string` | n/a | yes |
| name\_probe | The loadbalancer probe name. | `string` | `""` | no |
| probe\_port | Health check port definition. | `string` | `"80"` | no |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| backend\_pool\_ids | The IDs of the backend pools. |
| frontend\_ip\_configs | The Frontend configs of the loadbalancer. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
