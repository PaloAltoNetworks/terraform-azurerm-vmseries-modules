# Palo Alto Networks Application Gateway example

>Azure Application Gateway (AppGW) can make routing decisions based on additional attributes of an HTTP request, for example URI path or host headers. For example, you can route traffic based on the incoming URL. So if /images is in the incoming URL, you can route traffic to a specific set of servers (known as a pool) configured for images. If /video is in the URL, that traffic is routed to another pool that's optimized for videos. [More detail](https://docs.microsoft.com/en-us/azure/application-gateway/overview).

This folder shows an example of Terraform code that uses the [Palo Alto Networks Application Gateway](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/tree/develop/example/appgw) to deploy a single instance of application gateway using WAF capabilities. 

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
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| appgw\_name | The application gateway name. | `string` | n/a | yes |
| appgw\_subnet\_id | The loadbalancer probe name. | `string` | `null` | no |
| backend\_address\_pool\_name | The backend address pool name. | `string` | `"backend_http"` | no |
| frontend\_ip\_configuration\_name | The frontend ip configuration name. | `string` | `"frontend_ip_config_name"` | no |
| frontend\_port\_name | The frontend port name. | `string` | `"frontend_http"` | no |
| fw\_private\_ips | The private IP addresses list from deployed FW. | `list(string)` | `null` | no |
| http\_setting\_name | The http setting name. | `string` | `"http"` | no |
| listener\_name | The application gateway listener name. | `string` | `"http_listener"` | no |
| location | Region to deploy load balancer and dependencies. | `string` | `""` | no |
| request\_routing\_rule\_name | The routing rule name. | `string` | `"http_rule"` | no |
| resource\_group\_name | Name of the Resource Group to use. | `string` | n/a | yes |
| tags | The tag definition for application gateway. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| appgw\_publicip | Public address IP for application gateway listener. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
