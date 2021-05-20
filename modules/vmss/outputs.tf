# tflint-ignore: terraform_naming_convention # TODO rename to scale_set_name, but bundle with next breaking change
output "inbound-scale-set-name" {
  description = "Name of inbound scale set."
  value       = azurerm_virtual_machine_scale_set.this.name
}
