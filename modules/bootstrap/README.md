<!-- BEGIN_TF_DOCS -->


## Module's Required Inputs

Name | Type | Description
--- | --- | ---
[`name`](#name) | `string` | Name of the Storage Account, either a new or an existing one (depending on the value of `create_storage_account`).
[`resource_group_name`](#resource_group_name) | `string` | Name of the Resource Group to use.

## Module's Optional Inputs

Name | Type | Description
--- | --- | ---
[`create_storage_account`](#create_storage_account) | `bool` | If `true`, create a Storage Account.
[`location`](#location) | `string` | Region to deploy bootstrap resources.
[`min_tls_version`](#min_tls_version) | `string` | The minimum supported TLS version for the storage account.
[`files`](#files) | `map(string)` | Map of all files to copy to bucket.
[`bootstrap_files_dir`](#bootstrap_files_dir) | `string` | Bootstrap file directory.
[`files_md5`](#files_md5) | `map(string)` | Optional map of MD5 hashes of file contents.
[`storage_share_name`](#storage_share_name) | `string` | Name of a storage File Share to be created that will hold `files` used for bootstrapping.
[`storage_share_quota`](#storage_share_quota) | `number` | Maximum size of a File Share.
[`storage_share_access_tier`](#storage_share_access_tier) | `string` | Access tier for the File Share.
[`tags`](#tags) | `map(string)` | A map of tags to be associated with the resources created.
[`retention_policy_days`](#retention_policy_days) | `number` | Log retention policy in days.
[`blob_delete_retention_policy_days`](#blob_delete_retention_policy_days) | `number` | Specifies the number of days that the blob should be retained.
[`storage_allow_inbound_public_ips`](#storage_allow_inbound_public_ips) | `list(string)` | List of IP CIDR ranges (like `["23.
[`storage_allow_vnet_subnet_ids`](#storage_allow_vnet_subnet_ids) | `list(string)` | List of the allowed VNet subnet ids.
[`storage_acl`](#storage_acl) | `bool` | If `true`, storage account network rules will be activated with `Deny` as the default action.

## Module's Outputs

Name |  Description
--- | ---
[`storage_account`](#storage_account) | The Azure Storage Account object used for the Bootstrap
[`storage_share`](#storage_share) | The File Share object within Azure Storage used for the Bootstrap
[`primary_access_key`](#primary_access_key) | The primary access key for the Azure Storage Account

## Module's Nameplate

Requirements needed by this module:

- `terraform`, version: >= 1.2, < 2.0
- `azurerm`, version: ~> 3.25
- `random`, version: ~> 3.1

Providers used in this module:

- `azurerm`, version: ~> 3.25

Modules used in this module:
Name | Version | Source | Description
--- | --- | --- | ---

Resources used in this module:

- `storage_account` (managed)
- `storage_share` (managed)
- `storage_share_directory` (managed)
- `storage_share_file` (managed)
- `storage_account` (data)

## Inputs/Outpus details

### Required Inputs



#### name

Name of the Storage Account, either a new or an existing one (depending on the value of `create_storage_account`).

The name you choose must be unique across Azure. The name also must be between 3 and 24 characters in length, and may include only numbers and lowercase letters.


Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>

#### resource_group_name

Name of the Resource Group to use.

Type: `string`

<sup>[back to list](#modules-required-inputs)</sup>
















### Optional Inputs


#### create_storage_account

If `true`, create a Storage Account.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>



#### location

Region to deploy bootstrap resources. Ignored when `create_storage_account` is set to `false`.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### min_tls_version

The minimum supported TLS version for the storage account.

Type: `string`

Default value: `TLS1_2`

<sup>[back to list](#modules-optional-inputs)</sup>

#### files

Map of all files to copy to bucket. The keys are local paths, the values are remote paths.
Always use slash `/` as directory separator (unix-like), not the backslash `\`.
Example: 
```
files = {
  "dir/my.txt" = "config/init-cfg.txt"
}
```


Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### bootstrap_files_dir

Bootstrap file directory. If the variable has a value of `null` (default) - then it will not upload any other files other than the ones specified in the `files` variable. More information can be found at https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-package.

Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### files_md5

Optional map of MD5 hashes of file contents.
Normally the map could be empty, because all the files that exist before the `terraform apply` will have their hashes auto-calculated.
This input is necessary only for the selected files which are created/modified within the same Terraform run as this module.
The keys of the map should be identical with selected keys of the `files` input, while the values should be MD5 hashes of the contents of that file.

Example:
```
files_md5 = {
    "dir/my.txt" = "6f7ce3191b50a58cc13e751a8f7ae3fd"
}
```


Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_share_name

Name of a storage File Share to be created that will hold `files` used for bootstrapping.
For rules defining a valid name see [Microsoft documentation](https://docs.microsoft.com/en-us/rest/api/storageservices/Naming-and-Referencing-Shares--Directories--Files--and-Metadata#share-names).


Type: `string`

Default value: `&{}`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_share_quota

Maximum size of a File Share.

Type: `number`

Default value: `50`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_share_access_tier

Access tier for the File Share.

Type: `string`

Default value: `Cool`

<sup>[back to list](#modules-optional-inputs)</sup>

#### tags

A map of tags to be associated with the resources created.

Type: `map(string)`

Default value: `map[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### retention_policy_days

Log retention policy in days

Type: `number`

Default value: `7`

<sup>[back to list](#modules-optional-inputs)</sup>

#### blob_delete_retention_policy_days

Specifies the number of days that the blob should be retained

Type: `number`

Default value: `7`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_allow_inbound_public_ips

List of IP CIDR ranges (like `["23.23.23.23"]`) that are allowed to access the Storage Account.
Only public IPs are allowed - RFC1918 address space is not permitted.


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_allow_vnet_subnet_ids

List of the allowed VNet subnet ids.
Note that this option requires network service endpoint enabled for Microsoft Storage for the specified subnets.
If you are using [vnet module](../vnet/README.md) - set `storage_private_access` to true for the specific subnet.
Example:
```
[
  module.vnet.subnet_ids["subnet-mgmt"],
  module.vnet.subnet_ids["subnet-pub"],
  module.vnet.subnet_ids["subnet-priv"]
]
```


Type: `list(string)`

Default value: `[]`

<sup>[back to list](#modules-optional-inputs)</sup>

#### storage_acl

If `true`, storage account network rules will be activated with `Deny` as the default action. In such case, at least one of `storage_allow_inbound_public_ips` or `storage_allow_vnet_subnet_ids` must be a non-empty list.

Type: `bool`

Default value: `true`

<sup>[back to list](#modules-optional-inputs)</sup>


### Outputs


#### `storage_account`

The Azure Storage Account object used for the Bootstrap.

<sup>[back to list](#modules-outputs)</sup>
#### `storage_share`

The File Share object within Azure Storage used for the Bootstrap.

<sup>[back to list](#modules-outputs)</sup>
#### `primary_access_key`

The primary access key for the Azure Storage Account.

<sup>[back to list](#modules-outputs)</sup>
<!-- END_TF_DOCS -->