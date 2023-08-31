# Azurerm Provider configuration
provider "azurerm" {
  subscription_id = "53fc9b60-e863-4a92-a385-97d5cfe2d7ec"
  client_id       = "1105cb82-7c79-4a90-8822-45dc9f6f1c46"
  client_secret   = "tPU8Q~1V0gjs6g6exPXtio9vTncCuIBQEa0hqa22"
  tenant_id       = "0e083f14-f4a1-4950-846c-c36235ef9a6f"
  features {}
}

module "key-vault" {
  source  = "Ratan01/key-vault/azurerm"
  version = "2.2.0"

  # By default, this module will not create a resource group and expect to provide 
  # a existing RG name to use an existing resource group. Location will be same as existing RG. 
  # set the argument to `create_resource_group = true` to create new resrouce.
  resource_group_name        = "rg-keyvault"
  key_vault_name             = "keyvault-g1"
  key_vault_sku_pricing_tier = "premium"

  # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted
  # The default retention period is 90 days, possible values are from 7 to 90 days
  # use `soft_delete_retention_days` to set the retention period
  enable_purge_protection = false
  # soft_delete_retention_days = 90

  # Access policies for users, you can provide list of Azure AD users and set permissions.
  # Make sure to use list of user principal names of Azure AD users.
  access_policies = [
    {
      azure_ad_user_principal_names = ["user1@example.com", "user2@example.com"]
      key_permissions               = ["get", "list"]
      secret_permissions            = ["get", "list"]
      certificate_permissions       = ["get", "import", "list"]
      storage_permissions           = ["backup", "get", "list", "recover"]
    },

    # Access policies for AD Groups
    # to enable this feature, provide a list of Azure AD groups and set permissions as required.
    {
      azure_ad_group_names    = ["ADGroupName1", "ADGroupName2"]
      key_permissions         = ["get", "list"]
      secret_permissions      = ["get", "list"]
      certificate_permissions = ["get", "import", "list"]
      storage_permissions     = ["backup", "get", "list", "recover"]
    },

    # Access policies for Azure AD Service Principlas
    # To enable this feature, provide a list of Azure AD SPN and set permissions as required.
    {
      azure_ad_service_principal_names = ["azure-ad-dev-sp1", "azure-ad-dev-sp2"]
      key_permissions                  = ["get", "list"]
      secret_permissions               = ["get", "list"]
      certificate_permissions          = ["get", "import", "list"]
      storage_permissions              = ["backup", "get", "list", "recover"]
    }
  ]

  # Create a required Secrets as per your need.
  # When you Add `usernames` with empty password this module creates a strong random password
  # use .tfvars file to manage the secrets as variables to avoid security issues.
  secrets = {
    "message" = "Hello, world!"
    "vmpass"  = ""
  }

  # (Optional) To enable Azure Monitoring for Azure Application Gateway 
  # (Optional) Specify `storage_account_id` to save monitoring logs to storage. 
  log_analytics_workspace_id = var.log_analytics_workspace_id
  #storage_account_id         = var.storage_account_id

  # Adding additional TAG's to your Azure resources
  tags = {
    ProjectName  = "demo-project"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}