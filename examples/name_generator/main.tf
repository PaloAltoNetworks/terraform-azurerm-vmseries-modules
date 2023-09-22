terraform {}

variable "name_prefix" {
  default = "fosix"
}

variable "resource2template" {
  default = {
    default = ["vnet", "subnet"]
    storage = ["storage_account"]
  }
}

variable "name_templates" {
  default = {
    default = {
      delimiter = "-"
      parts = [
        { prefix = null },
        { bu = "rnd" },
        { env = "prd" },
        { name = "%s" },
        { abbreviation = "__default__" },
      ]
    }
    storage = {
      delimiter = ""
      parts = [
        { prefix = null },
        { org = "palo" },
        { env = "prd" },
        { name = "%s" },
      ]
    }
  }
}

module "name_templates" {
  source = "../../modules/name_templater"

  for_each = { for k, v in transpose(var.resource2template) : k => v[0] }

  resource_type = each.key
  name_template = var.name_templates[each.value]
  name_prefix   = var.name_prefix
}

output "template" {
  value = { for k, v in module.name_templates : k => v.template }
}