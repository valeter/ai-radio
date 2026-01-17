resource "kubernetes_ingress_v1" "this" {
  count = var.ingress_enabled ? 1 : 0

  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels    = local.common_labels

    annotations = {
      "ingress.alb.yc.io/subnets"               = var.yc_alb_subnets
      "ingress.alb.yc.io/security-groups"       = var.yc_alb_security_groups
      "ingress.alb.yc.io/external-ipv4-address" = var.yc_alb_external_ipv4
      "ingress.alb.yc.io/group-name"            = var.yc_alb_group_name
      "ingress.alb.yc.io/group-settings-name"   = "base-settings"
      "rollme" = "${random_id.rollme.hex}"
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts       = [var.ingress_host]
      secret_name = var.yc_tls_secret_name
    }

    rule {
      host = var.ingress_host

      http {
        path {
          path      = var.ingress_path
          path_type = var.ingress_path_type

          backend {
            service {
              name = local.app_name

              port {
                name = "nginx"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace_v1.this,
    kubernetes_service_v1.this,
    kubectl_manifest.ingress_group_settings
  ]
}

resource "random_id" "rollme" {
  keepers = {
    # Генерировать новый id при изменении конфигурации Ingress
    config = jsonencode(local.common_labels)
  }
  byte_length = 5
}