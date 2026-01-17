resource "kubernetes_namespace_v1" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name   = local.namespace
    labels = local.common_labels
  }
}
