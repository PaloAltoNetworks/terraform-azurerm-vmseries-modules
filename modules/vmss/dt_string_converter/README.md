<!-- BEGIN_TF_DOCS -->
# Palo Alto Date/Time string representation converted

This is a very simple module used solely to convert time in minutes to a string representation required by the
Azure Scale Set's autoscaling metrics rules.

It's a sub module of the `vmss` module created to deduplicate code required to perform the conversion between
two formats. It was not designed to be used outside of the `vmss` module.

## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`time`](#time) | `number` | The time value in minutes to be converted to string representation.




## Module's Outputs

Name |  Description
--- | ---
`dt_string` | Azure string time representation.

## Module's Nameplate









## Inputs/Outpus details

### Required Inputs


#### time

The time value in minutes to be converted to string representation.

Type: number

<sup>[back to list](#modules-required-inputs)</sup>



<!-- END_TF_DOCS -->