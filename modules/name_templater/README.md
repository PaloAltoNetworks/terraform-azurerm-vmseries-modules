# Name Templater module

A module to generate resource name template.


## Purpose

There are situations where simple name prefixing is not enough. More complex structures are required.
This module generates a string template that can be used with Terraform's `format()` function to generate the actual resource name.

## Usage

A simple module invocation might look like the following:

```hcl
module "name_templates" {
  source = "../../modules/name_templater"

  resource_type = "vnet"
  name_template = {
    delimiter = "-"
    parts = [
      { prefix = null },
      { bu = "rnd" },
      { randomize = "__random__" },
      { env = "prd" },
      { name = "%s" },
      { abbreviation = "__default__" },
    ]
  }
  name_prefix   = "a_prefix"
}
```

The value the module will output for such invocation would be `"a_prefix-rnd-crediblefrog-prd-%s-vnet"`.

As you can see:

* all `parts` values are *glued* together to form a template name
* the `prefix` key is just a placeholder that eventually is replaced with the value of `name_prefix`
* the `__random__` string is replaced with a name of a [random pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (in case you need to randomize some name, for testing purposes for example)
* the `__default__` string is replaced with a resource abbreviation.
  
  This abbreviations are defined with `var.abbreviations` variable. The module contains basic abbreviations following Microsoft suggestions, but they can be overriden with custom definitions.
  
  The important part is that the `resource_type` has to match an entry in `abbreviations` variable, otherwise the abbreviation will be replaced with an empty string.

To create the actual resource name the following code can be used:

```hcl
vnet_name = format(module.name_templates.template, "transit")
```

Following the values above the actual resource name would be `"a_prefix-rnd-crediblefrog-prd-transit-vnet"`.

## Reference

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_type"></a> [resource\_type](#input\_resource\_type) | A type of resource for which the name template will be created. This should follow the abbreviations resource naming standard. | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used in names for the resources. | `string` | n/a | yes |
| <a name="input_name_template"></a> [name\_template](#input\_name\_template) | A name template definition.<br><br>Consist of two elements:<br><br>- `parts` - a list of elements that will form the template name<br>- `delimiter` - a string that will be used to separate the elements.<br><br>There are couple of rules to be followed:<br><br>- the order **DOES** matter<br>- `parts` is a list of single element maps<br>- keys in `parts` elements will be dropped, they are only informational, only values will be used<br>- value for the `prefix` key will be replaced with the `var.name_prefix` value<br>- a value of `__default__` will be replaced with an abbreviation defined in the `var.abbrevations` and matching `var.resource_type`.<br>- since this module generates template name do **REMEMBER** to include a part with `%s` value <br><br>Example:<pre>default = {<br>  default = {<br>    delimiter = "-"<br>    parts = [<br>      { prefix = null },<br>      { bu = "rnd" },<br>      { env = "prd" },<br>      { name = "%s" },<br>      { abbreviation = "__default__" },<br>    ]<br>  }<br>  storage = {<br>    delimiter = ""<br>    parts = [<br>      { prefix = null },<br>      { org = "palo" },<br>      { env = "prd" },<br>      { name = "%s" },<br>    ]<br>  }<br>}</pre> | <pre>object({<br>    delimiter = string<br>    parts     = list(map(string))<br>  })</pre> | n/a | yes |
| <a name="input_abbreviations"></a> [abbreviations](#input\_abbreviations) | Map of abbreviations used for resources (placed in place of "\_\_default\_\_").<br><br>These abbreviations are based on [Microsoft suggestions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations). | `map(string)` | <pre>{<br>  "application_gw": "agw",<br>  "application_insights": "appi",<br>  "availability_set": "avail",<br>  "bastion": "bas",<br>  "data_disk": "disk",<br>  "file_share": "share",<br>  "load_balancer": "lb",<br>  "log_analytics_workspace": "log",<br>  "managed_identity": "id",<br>  "nat_gw": "ng",<br>  "network_interface": "nic",<br>  "nsg": "nsg",<br>  "nsg_rule": "nsgsr",<br>  "os_disk": "osdisk",<br>  "public_ip": "pip",<br>  "public_ip_prefix": "ippre",<br>  "resource_group": "rg",<br>  "route_table": "rt",<br>  "service_endpoint": "se",<br>  "storage_account": "st",<br>  "subnet": "snet",<br>  "udr": "udr",<br>  "virtual_machine": "vm",<br>  "virtual_machine_scale_set": "vmss",<br>  "virtual_network_gateway": "vgw",<br>  "vnet": "vnet",<br>  "vnet_peering": "peer"<br>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_template"></a> [template](#output\_template) | A template string that can be used with `format` function to generate a resource name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
