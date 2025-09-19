output "namespace" {
  description = "The Kubernetes namespace where Strapi is deployed"
  value       = kubernetes_namespace.strapi.metadata[0].name
}

output "postgres_service_name" {
  description = "The PostgreSQL service name"
  value       = "${var.name}-postgresql"
}

output "postgres_connection_info" {
  description = "PostgreSQL connection information"
  value = {
    host     = "${var.name}-postgresql"
    port     = 5432
    database = "strapi"
    username = "postgres"
  }
  sensitive = false
}

output "strapi_service_name" {
  description = "The Strapi service name"
  value       = kubernetes_service.strapi.metadata[0].name
}

output "strapi_service_port" {
  description = "The Strapi service port"
  value       = 1337
}

output "uploads_pvc_name" {
  description = "The name of the Strapi uploads PVC"
  value       = kubernetes_persistent_volume_claim.strapi_uploads.metadata[0].name
}