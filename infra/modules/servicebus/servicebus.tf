terraform {
  required_providers {
    azurerm = {
      version = "~>3.47.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.24"
    }
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy Service Bus namespace
# ------------------------------------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name

  sku            = "Standard"
  zone_redundant = false

  tags = var.tags
}

resource "azurerm_servicebus_queue" "queue_01" {
  name                = "upper-case"
  namespace_id        = azurerm_servicebus_namespace.servicebus_namespace.id

  enable_partitioning   = false
  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
  requires_session      = false
  default_message_ttl   = "P14D"
}

resource "azurerm_servicebus_queue" "queue_02" {
  name                = "lower-case"
  namespace_id        = azurerm_servicebus_namespace.servicebus_namespace.id

  enable_partitioning   = false
  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
  requires_session      = false
  default_message_ttl   = "P14D"
}
