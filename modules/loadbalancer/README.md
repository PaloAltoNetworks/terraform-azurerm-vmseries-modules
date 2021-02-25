# Palo Alto Networks inbound/outbound Load Balancer Module for Azure

A terraform module for deploying an inbound/Outbound Load Balancer for VM-Series firewalls. Supports both standalone and scaleset deployments.

## Usage

```hcl
# Deploy the inbound load balancer for traffic into the azure environment
module "inbound-lb" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/modules/loadbalancer"

  location     = "Australia Central"
  name_prefix  = "pan"
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

  location     = "Australia Central"
  name_prefix  = "pan"
  frontend_ips = {
    internal_fe = {
      subnet_id                     = ""
      private_ip_address_allocation = "Static" // Dynamic or Static
      private_ip_address = "10.0.1.6" 
      rules = {
        HA_PORTS = {
          port         = 0
          protocol     = "All"
          backend_name = "backend1_name"
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
| terraform | >=0.12.29, <0.14 |
| azurerm | >=2.26.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >=2.26.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| frontend\_ips | A map of objects describing LB Frontend IP configurations. Keys of the map are the names and values are { create\_public\_ip, public\_ip\_address\_id, rules }. Example:<pre>//public<br>{<br>  pip-existing = {<br>    create_public_ip     = false<br>    public_ip_address_id = azurerm_public_ip.this.id<br>    rules = {<br>      HTTP = {<br>        port         = 80<br>        protocol     = "Tcp"<br>        backend_name = "backend1_name"<br>      }<br>    }<br>  }<br>  pip-create = {<br>    create_public_ip = true<br>    rules = {<br>      HTTPS = {<br>        port         = 8080<br>        protocol     = "Tcp"<br>        backend_name = "backend2_name"<br>      }<br>      SSH = {<br>        port         = 22<br>        protocol     = "Tcp"<br>        backend_name = "backend3_name"<br>      }<br>    }<br>  }<br>}<br>//private<br>{<br>  internal_fe = {<br>    subnet_id                     = subnet.id<br>    private_ip_address_allocation = "Dynamic" // Dynamic or Static<br>    #private_ip_address = "10.0.1.6" <br>    rules = {<br>      HA_PORTS = {<br>        port         = 0<br>        protocol     = "All"<br>        backend_name = "backend1_name"<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| location | Region to deploy load balancer and dependencies. | `string` | `""` | no |
| name\_backend | n/a | `string` | `"lb-backend"` | no |
| name\_lb | n/a | `string` | `"lb"` | no |
| name\_prefix | Prefix to add to all the object names here | `any` | n/a | yes |
| name\_probe | n/a | `string` | `"lb-probe"` | no |
| probe\_port | n/a | `string` | `"80"` | no |
| resource\_group\_name | n/a | `string` | `"lb-rg"` | no |
| sep | Seperator | `string` | `"-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| backend-pools-id | The ID of the backend pools. |
| frontend-ip-configs | IP config resources of the load balancer. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
