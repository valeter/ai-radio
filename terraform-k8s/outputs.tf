output "namespace" {
  description = "Kubernetes namespace"
  value       = local.namespace
}

output "deployment_name" {
  description = "Deployment name"
  value       = kubernetes_deployment_v1.this.metadata[0].name
}

output "service_name" {
  description = "Service name"
  value       = kubernetes_service_v1.this.metadata[0].name
}

output "service_account_name" {
  description = "Service account name"
  value       = kubernetes_service_account_v1.this.metadata[0].name
}

output "ingress_host" {
  description = "Ingress host"
  value       = var.ingress_host
}

output "ingress_url" {
  description = "Application URL"
  value       = "https://${var.ingress_host}"
}
