variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "name" {
  description = "Name of Spring App Service instance"
  type        = string
}

variable "service_bus_connection_string" {
  description = "Connect string of Service Bus"
  type        = string
}
