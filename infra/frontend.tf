resource "azurerm_static_web_app" "swa" {
  name                = "swa-${var.project_prefix}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  app_settings = {
    "CosmosDbConnectionString" = azurerm_cosmosdb_account.db.primary_sql_connection_string
  }
}

resource "azurerm_static_web_app_custom_domain" "domain" {
  static_web_app_id = azurerm_static_web_app.swa.id
  domain_name       = var.custom_domain_name
  validation_type   = "cname-delegation"
}