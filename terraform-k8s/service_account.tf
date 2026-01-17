resource "kubernetes_service_account_v1" "this" {
  count = var.create_service_account ? 1 : 0

  metadata {
    name      = local.service_account_name
    namespace = local.namespace
    labels    = local.common_labels
  }

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  count = var.create_service_account && var.service_account_cluster_admin ? 1 : 0

  metadata {
    name   = local.service_account_name
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.service_account_name
    namespace = local.namespace
  }

  depends_on = [kubernetes_service_account_v1.this]
}

resource "kubernetes_secret_v1" "service_account_token" {
  count = var.create_service_account ? 1 : 0

  metadata {
    name      = "${local.service_account_name}-token"
    namespace = local.namespace
    labels    = local.common_labels

    annotations = {
      "kubernetes.io/service-account.name" = local.service_account_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [kubernetes_service_account_v1.this]
}
