variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "strapi"
}

variable "namespace_name" {
  description = "Kubernetes namespace name"
  type        = string
  default     = "strapi"
}

variable "strapi_version" {
  description = "Strapi container image tag"
  type        = string
  default     = "5.1.0"
}

variable "postgres_password" {
  description = "PostgreSQL password (from Infisical secret)"
  type        = string
  sensitive   = true
}

variable "storage_class_name" {
  description = "Storage class name for PVCs"
  type        = string
}

variable "replicas" {
  description = "Number of Strapi replicas"
  type        = number
  default     = 1
}

variable "postgres_storage_size" {
  description = "PostgreSQL storage size"
  type        = string
  default     = "10Gi"
}

variable "strapi_uploads_storage_size" {
  description = "Strapi uploads storage size"
  type        = string
  default     = "5Gi"
}

variable "strapi_admin_jwt_secret" {
  description = "Strapi admin JWT secret (from Infisical)"
  type        = string
  sensitive   = true
}

variable "strapi_api_token_salt" {
  description = "Strapi API token salt (from Infisical)"
  type        = string
  sensitive   = true
}

variable "strapi_app_keys" {
  description = "Strapi app keys (from Infisical)"
  type        = string
  sensitive   = true
}