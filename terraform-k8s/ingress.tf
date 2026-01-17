resource "kubernetes_ingress_v1" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels    = local.common_labels

    annotations = {
      "gwin.yandex.cloud/securityGroups"       = var.yc_alb_security_groups
      "gwin.yandex.cloud/externalIPv4Address"  = var.yc_alb_external_ipv4
      "gwin.yandex.cloud/rules.allowedMethods" = "GET"
      "gwin.yandex.cloud/groupName"            = var.yc_alb_group_name
      "rollme"                                 = "${random_id.rollme.hex}"
    }
  }

  spec {
    ingress_class_name = "gwin-default"

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
    kubernetes_service_v1.this
  ]
}

resource "random_id" "rollme" {
  keepers = {
    # Генерировать новый id при изменении конфигурации Ingress
    config = jsonencode(local.common_labels)
  }
  byte_length = 5
}
