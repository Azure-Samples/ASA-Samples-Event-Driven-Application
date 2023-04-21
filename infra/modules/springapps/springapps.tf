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
    azapi = {
      source = "Azure/azapi"
      version = "~>1.1.0"
    }
  }
}


data "azurerm_subscription" "current" {}


resource "azurerm_spring_cloud_service" "asa_instance" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location
  sku_name            = "S0"

  tags = var.tags
}


resource "azurerm_spring_cloud_app" "asa_app" {
  name                = "event-driven"
  resource_group_name = var.rg_name
  service_name        = azurerm_spring_cloud_service.asa_instance.name

  is_public = true

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_spring_cloud_java_deployment" "deployment" {
  name                = "default"
  spring_cloud_app_id = azurerm_spring_cloud_app.asa_app.id
  instance_count      = 1

  quota {
    cpu    = "1"
    memory = "2Gi"
  }

  runtime_version = "Java_17"

  environment_variables = {
    "Env" : "Staging"
    "SERVICE_BUS_CONNECTION_STRING": var.service_bus_connection_string
  }
}