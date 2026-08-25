variable "resource_group_name" {
  description = "The name of our existing Azure Resource Group"
  type        = string
  default     = "rg-portfolio-prod"
}

variable "location" {
  description = "The Azure Region"
  type        = string
  default     = "East US" # Change this if your resource group is in a different region (e.g., "West US")
}