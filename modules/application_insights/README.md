<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs


- [`name`](#name)
- [`location`](#location)
- [`resource_group_name`](#resource_group_name)


### name

Name of the Application Insights instance.

Type: `string`





### location

A name of a region in which the resources will be creatied.

Type: `string`

### resource_group_name

A name of an existing Resource Group.

Type: `string`



## Module's Optional Inputs


- [`workspace_mode`](#workspace_mode)
- [`workspace_name`](#workspace_name)
- [`workspace_sku`](#workspace_sku)
- [`metrics_retention_in_days`](#metrics_retention_in_days)
- [`tags`](#tags)



### workspace_mode

Application Insights mode. If `true` (default), the 'Workspace-based' mode is used. With `false`, the mode is set to legacy 'Classic'.

NOTICE. Azure support for classic Application Insights mode will end on Feb 29th 2024. It's already not available in some of the new regions.


Type: `bool`

Default value: `true`

### workspace_name

The name of the Log Analytics workspace. Can be `null`, in which case a default name is auto-generated.

Type: `string`

Default value: `&{}`

### workspace_sku

Azure Log Analytics Workspace mode SKU. For more information refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/azure/azure-monitor//usage-estimated-costs#moving-to-the-new-pricing-model).

Type: `string`

Default value: `PerGB2018`

### metrics_retention_in_days

Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Azure defaults is 90.

Type: `number`

Default value: `&{}`



### tags

A map of tags assigned to all resources created by this module.

Type: `map(string)`

Default value: `map[]`


## Module's Outputs


- [`metrics_instrumentation_key`](#metrics_instrumentation_key)
- [`application_insights_id`](#application_insights_id)


* `metrics_instrumentation_key`: The Instrumentation Key of the created instance of Azure Application Insights. 
  
The instance is unused by default, but is ready to receive custom PAN-OS metrics from the firewalls. To use it, paste this Instrumentation Key into PAN-OS -> Device -> VM-Series -> Azure.

* `application_insights_id`: An Azure ID of the Application Insights resource created by this module.

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

Resources used in this module:

- `application_insights` (managed)
- `log_analytics_workspace` (managed)
<!-- END_TF_DOCS -->