resource "kubectl_manifest" "ingress_group_settings" {
  count = var.ingress_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "alb.yc.io/v1alpha1"
    kind       = "IngressGroupSettings"
    metadata = {
      name      = "base-settings"
      namespace = local.namespace
    }
    logOptions = {
      logGroupID = var.yc_alb_log_group_id
    }
  })
}