resource "azurerm_static_web_app" "swa" {
  name                = "swa-${var.project_prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
}

resource "azurerm_static_web_app_custom_domain" "domain" {
  count             = var.enable_custom_domain ? 1 : 0
  domain_name       = var.custom_domain_name
  static_web_app_id = azurerm_static_web_app.swa.id
  validation_type   = "cname-delegation"
}

output "swa_default_hostname" {
  description = "Copy this default hostname to configure your DNS CNAME record."
  value       = azurerm_static_web_app.swa.default_host_name
}