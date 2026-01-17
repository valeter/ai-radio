resource "kubernetes_horizontal_pod_autoscaler_v2" "this" {
  count = var.hpa_enabled ? 1 : 0

  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels    = local.common_labels
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = local.app_name
    }

    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = var.hpa_target_cpu_utilization
        }
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.this]
}
