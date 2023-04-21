locals {
  tags                         = { azd-env-name : var.environment_name, spring-cloud-azure : true }
  sha                          = base64encode(sha256("${var.environment_name}${var.location}${data.azurerm_client_config.current.subscription_id}"))
  resource_token               = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
  psql_custom_username         = "CUSTOM_ROLE"
}
# ------------------------------------------------------------------------------------------------------
# Deploy resource Group
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "rg_name" {
  name          = var.environment_name
  resource_type = "azurerm_resource_group"
  random_length = 0
  clean_input   = true
}

resource "azurerm_resource_group" "rg" {
  name     = azurecaf_name.rg_name.result
  location = var.location

  tags = local.tags
}
## ------------------------------------------------------------------------------------------------------
## Deploy Service Bus
## ------------------------------------------------------------------------------------------------------
module "servicebus" {
  name           = "asb-${local.resource_token}"
  source         = "./modules/servicebus"
  location       = var.location
  rg_name        = azurerm_resource_group.rg.name
  tags           = local.tags
}
# ------------------------------------------------------------------------------------------------------
# Deploy Azure Spring Apps
# ------------------------------------------------------------------------------------------------------
module "asa_api" {
  name                          = "asa-${local.resource_token}"
  source                        = "./modules/springapps"
  location                      = var.location
  rg_name                       = azurerm_resource_group.rg.name
  service_bus_connection_string = module.servicebus.SERVICEBUS_CONNECTION_STRING

  tags                          = merge(local.tags, { azd-service-name : "event-driven" })
}
