locals {
  app_name  = var.app_name
  namespace = var.namespace

  common_labels = merge({
    "app.kubernetes.io/name"       = local.app_name
    "app.kubernetes.io/instance"   = local.app_name
    "app.kubernetes.io/managed-by" = "terraform"
  }, var.labels)

  selector_labels = {
    "app.kubernetes.io/name"     = local.app_name
    "app.kubernetes.io/instance" = local.app_name
  }

  service_account_name = "${local.app_name}-sa"
}
