output "SERVICEBUS_CONNECTION_STRING" {
  value       = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
  description = "The connection string of Service Bus namespace."
  sensitive   = true
}
