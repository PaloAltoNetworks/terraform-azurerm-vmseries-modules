# --- GENERAL --- #
location            = "North Europe"
resource_group_name = "app-insights-refactor"
name_prefix         = "fosix-"
tags = {
  "CreatedBy"   = "Palo Alto Networks"
  "CreatedWith" = "Terraform"
}

ngfw_metrics = {
  name                = "fosix-brownfield-law"
  create_workspace    = false
  resource_group_name = "fosix-app-insights-refactor-brownfield"
  application_insights = {
    ai1 = {
      name = "ai-1"
    }
    ai2 = {
      name                = "ai-2"
      resource_group_name = "fosix-app-insights-refactor-brownfield"
    }
  }
}