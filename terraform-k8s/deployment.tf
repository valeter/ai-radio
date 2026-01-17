resource "kubernetes_deployment_v1" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels    = local.common_labels
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = local.selector_labels
    }

    template {
      metadata {
        labels = local.selector_labels
      }

      spec {
        service_account_name = local.service_account_name

        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secrets
          content {
            name = image_pull_secrets.value
          }
        }

        container {
          name              = local.app_name
          image             = "${var.image_repository}:${var.image_tag}"
          image_pull_policy = var.image_pull_policy

          port {
            name           = "nginx"
            container_port = var.container_port
          }

          security_context {
            privileged = var.privileged
          }

          resources {
            requests = {
              cpu    = var.resources_requests_cpu
              memory = var.resources_requests_memory
            }

            limits = var.resources_limits_cpu != null || var.resources_limits_memory != null ? {
              cpu    = var.resources_limits_cpu
              memory = var.resources_limits_memory
            } : null
          }

          liveness_probe {
            http_get {
              path = var.health_probe_path
              port = var.container_port
            }
          }

          readiness_probe {
            http_get {
              path = var.health_probe_path
              port = var.container_port
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace_v1.this,
    kubernetes_service_account_v1.this
  ]
}
