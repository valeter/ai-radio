resource "kubernetes_service_v1" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels    = local.common_labels
  }

  spec {
    type     = var.service_type
    selector = local.selector_labels

    port {
      name        = "nginx"
      port        = var.container_port
      target_port = var.container_port
    }
  }

  depends_on = [kubernetes_namespace_v1.this]
}
