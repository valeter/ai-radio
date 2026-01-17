resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = local.namespace
    labels = local.common_labels
  }
}
