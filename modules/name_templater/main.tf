resource "random_pet" "this" {
  count = contains(
    flatten([for e in var.name_template.parts : [for _, v in e : v]]),
    "__random__"
  ) ? 1 : 0
  separator = ""
  length    = 2
}

locals {
  template_parts = flatten([
    for part in var.name_template.parts : [
      for part_name, part_value in part : part_name == "prefix" ? var.name_prefix : part_value
    ]
  ])

  template_raw = join(var.name_template.delimiter, local.template_parts)

  template_abbreviated = replace(
    local.template_raw,
    "__default__",
    try(var.abbreviations[var.resource_type], "")
  )

  template_randomized = can(random_pet.this[0].id) ? replace(
    local.template_abbreviated,
    "__random__",
    try(random_pet.this[0].id, "")
  ) : local.template_abbreviated

  template_trimmed = trim(local.template_randomized, var.name_template.delimiter)

}