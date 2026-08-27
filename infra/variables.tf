variable "project_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "enable_custom_domain" {
  type        = bool
  description = "Feature flag to enable custom domain binding after CNAME is verified"
  default     = false
}

variable "custom_domain_name" {
  type        = string
  description = "The custom domain for the portfolio website"
}