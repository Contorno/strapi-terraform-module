# Strapi Terraform Module

A Terraform module for deploying Strapi CMS with a managed PostgreSQL database on Kubernetes.

## Features

- **Strapi CMS**: Deploys the official Strapi container with a configurable image tag
- **PostgreSQL Database**: Installs the Bitnami PostgreSQL Helm chart with persistent storage
- **Secrets Management**: Provisions Kubernetes secrets for PostgreSQL credentials and Strapi keys
- **Persistent Uploads**: Creates a dedicated PVC for the Strapi uploads directory
- **Configurable Capacity**: Tunable storage sizes and replica counts
- **Health Probes**: Liveness and readiness probes for the Strapi deployment

## Requirements

- Kubernetes cluster with a working storage class
- Terraform Kubernetes and Helm providers configured
- Values for Strapi secrets (can be sourced from Infisical or another secret manager)

## Usage

```hcl
module "strapi" {
  source = "git::https://github.com/Contorno/strapi-terraform-module.git?ref=v0.1.0"

  name               = "strapi"
  namespace_name     = "strapi"
  strapi_version     = "5.1.0"
  postgres_password  = local.strapi_postgres_pw
  storage_class_name = kubernetes_storage_class.k8s_hostpath.metadata[0].name

  # Optional values
  replicas                    = 1
  postgres_storage_size       = "10Gi"
  strapi_uploads_storage_size = "5Gi"

  # Secrets (mark as sensitive in your state)
  strapi_admin_jwt_secret = local.strapi_admin_jwt_secret
  strapi_api_token_salt   = local.strapi_api_token_salt
  strapi_app_keys         = local.strapi_app_keys
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | `"strapi"` | no |
| namespace_name | Kubernetes namespace name | `string` | `"strapi"` | no |
| strapi_version | Strapi container image tag | `string` | `"5.1.0"` | no |
| postgres_password | PostgreSQL password | `string` | n/a | yes |
| storage_class_name | Storage class name for PVCs | `string` | n/a | yes |
| replicas | Number of Strapi replicas | `number` | `1` | no |
| postgres_storage_size | PostgreSQL storage size | `string` | `"10Gi"` | no |
| strapi_uploads_storage_size | Strapi uploads storage size | `string` | `"5Gi"` | no |
| strapi_admin_jwt_secret | Strapi admin JWT secret | `string` | n/a | yes |
| strapi_api_token_salt | Strapi API token salt | `string` | n/a | yes |
| strapi_app_keys | Strapi app keys (comma-separated string) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Kubernetes namespace where Strapi is deployed |
| postgres_service_name | PostgreSQL service name |
| postgres_connection_info | PostgreSQL connection details (host, port, database, username) |
| strapi_service_name | Strapi service name |
| strapi_service_port | Strapi service port |
| uploads_pvc_name | Name of the Strapi uploads PVC |

## Architecture

- **PostgreSQL**: Managed by the Bitnami Helm chart with persistent volumes for data
- **Strapi Deployment**: Runs as a Kubernetes Deployment with environment variables wired to secrets
- **Storage**: Separate PVC mounts `/opt/app/public/uploads` for persisted media
- **Networking**: Exposes Strapi via a ClusterIP service (ingress configuration is left to the caller)
- **Security**: Sensitive values are stored in Kubernetes secrets and consumed by the deployment

## Future Enhancements

- Ingress and TLS automation via cert-manager
- Redis integration for session storage and caching
- Horizontal Pod Autoscaling (HPA)
- MinIO/S3 integration for uploads
- Database backup automation
- Monitoring and logging integration

## License

MIT
