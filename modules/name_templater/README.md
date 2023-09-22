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
      { env = "prd" },
      { name = "%s" },
      { abbreviation = "__default__" },
    ]
  }
  name_prefix   = "a_prefix"
}
```

The value the module will output for such invocation would be `"a_prefix-rnd-prd-%s-vnet"`.

As you can see:

* all parts' values are *glued* together to form a template name
* the `prefix` key is just a placeholder that eventually is replaced with the value of `name_prefix`
* the `__default__` string is replaced with a resource abbreviation.
  
  This abbreviations are defined with `var.abbreviations` variable. The module contains basic abbreviations following Microsoft suggestions, but they can be overriden with custom definitions. 
  
  The important part is that the `resource_type` has to match an entry in `abbreviations` variable, otherwise the abbreviation will be replaced with an empty string.

To create the actual resource name the following code can be used:

```hcl
vnet_name = format(module.name_templates.template, "transit")
```

Following the values above the actual resource name would be `"a_prefix-rnd-prd-transit-vnet"`.

## Reference

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
