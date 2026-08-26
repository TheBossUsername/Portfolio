output "swa_deployment_token" {
  value     = azurerm_static_web_app.swa.api_key
  sensitive = true
}