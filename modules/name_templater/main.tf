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

  template_trimmed = trim(local.template_abbreviated, var.name_template.delimiter)

}