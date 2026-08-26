resource "azurerm_cosmosdb_account" "db" {
  name = "cosmos-${var.project_prefix}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "sqldb" {
  name                = "ResumeDB"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.db.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "Counter"
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.db.name
  database_name       = azurerm_cosmosdb_sql_database.sqldb.name
  partition_key_path  = "/id"
}

resource "azurerm_cosmosdb_sql_container_item" "counter_item" {
  container_name      = azurerm_cosmosdb_sql_container.container.name
  database_name       = azurerm_cosmosdb_sql_database.sqldb.name
  account_name        = azurerm_cosmosdb_account.db.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_key       = "1"
  
  body = jsonencode({
    "id"    = "1"
    "count" = 0
  })
}