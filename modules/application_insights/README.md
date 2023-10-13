<!-- BEGIN_TF_DOCS -->
# Palo Alto Networks Application Insights Module for Azure

A Terraform module for deploying a Application Insights in Azure cloud.

Azure AI can be used to gather metric from Palo Alto's VMSeries firewall. This can be done for both a standalone firewall as for a Scale Set deployment.

In both situations the instrumentation key for the Application Insights has to be provided in the firewall's configuration. For more information please refer to [documentation](https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-azure/enable-azure-application-insights-on-the-vm-series-firewall).

**NOTICE**

* This module deploys Application Insights in Workspace mode (together with a Log Analytics Workspace). Azure support for classic Application Insights mode will end on Feb 29th 2024 hence it is not supported in the module.

* The metrics gathered within a single Azure Application Insights instance provided by the module, cannot be split back to obtain a result for a single firewall. Thus for example if three firewalls use the same Instrumentation Key and report their respective session utilizations as 90%, 20%, 10%, it is possible to see in Azure the average of 40%, the sum of 120%, the max of 90%, but it is *not possible* to know which of the firewalls reported the 90% utilization.

* Since upgrade to provider 3.x, when destroying infrastructure a resource is being left behind: `microsoft.alertsmanagement/smartdetectoralertrules`. This resource is not present in the state nor code, it's being created by Azure automatically and therefore it prevents resource group deletion. A workaround is to set the following provider configuration:

      provider "azurerm" {
        features {
          resource\_group {
            prevent\_deletion\_if\_contains\_resources = false
          }
        }
      }

## Usage

The following snippet deploys Application Insights and Log Analytics Workspace, setting the retention to 1 year.

```hcl
module "ai" {
  source = "PaloAltoNetworks/vmseries-modules/azurerm//modules/application_insights"

  name                      = "vmseries-ai
  metrics_retention_in_days = 365
  location                  = "West US"
  resource_group_name       = "vmseries-rg"
}
```

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | Name of the Application Insights instance.
[`resource_group_name`](#resource_group_name) | `string` | A name of an existing Resource Group.
[`location`](#location) | `string` | A name of a region in which the resources will be created.
[`workspace_name`](#workspace_name) | `string` | The name of the Log Analytics workspace.


## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`tags`](#tags) | `map` | A map of tags assigned to all resources created by this module.
[`workspace_sku`](#workspace_sku) | `string` | Azure Log Analytics Workspace mode SKU.
[`metrics_retention_in_days`](#metrics_retention_in_days) | `number` | Specifies the retention period in days.



## Module's Outputs

Name |  Description
--- | ---
`metrics_instrumentation_key` | The Instrumentation Key of the created instance of Azure Application Insights.
`application_insights_id` | An Azure ID of the Application Insights resource created by this module.

## Module's Nameplate


Requirements needed by this module:

- `terraform`, version: >= 1.3, < 2.0
- `azurerm`, version: ~> 3.25


Providers used in this module:

- `azurerm`, version: ~> 3.25




Resources used in this module:

- `application_insights` (managed)
- `log_analytics_workspace` (managed)

## Inputs/Outpus details

### Required Inputs


#### name

Name of the Application Insights instance.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

A name of an existing Resource Group.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>

#### location

A name of a region in which the resources will be created.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>


#### workspace_name

The name of the Log Analytics workspace.

Type: string

<sup>[back to list](#modules-required-inputs)</sup>





### Optional Inputs





#### tags

A map of tags assigned to all resources created by this module.

Type: map(string)

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>


#### workspace_sku

Azure Log Analytics Workspace mode SKU. For more information refer to [Microsoft's documentation](https://learn.microsoft.com/en-us/azure/azure-monitor//usage-estimated-costs#moving-to-the-new-pricing-model).

Type: string

Default value: `PerGB2018`

<sup>[back to list](#modules-optional-inputs)</sup>

#### metrics_retention_in_days

Specifies the retention period in days. Possible values are 0, 30, 60, 90, 120, 180, 270, 365, 550 or 730. Azure defaults is 90.

Type: number

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>


<!-- END_TF_DOCS -->