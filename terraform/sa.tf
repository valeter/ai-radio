// alb
resource "yandex_iam_service_account" "alb-sa" {
  name      = "alb-sa"
  folder_id = local.sa_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "alb-sa-alb-editor" {
  folder_id = local.network_folder_id
  role      = "alb.editor"
  member    = "serviceAccount:${yandex_iam_service_account.alb-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "alb-sa-public-admin" {
  folder_id = local.network_folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.alb-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "alb-sa-private-admin" {
  folder_id = local.network_folder_id
  role      = "vpc.privateAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.alb-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "alb-sa-cert-downloader" {
  folder_id = local.network_folder_id
  role      = "certificate-manager.certificates.downloader"
  member    = "serviceAccount:${yandex_iam_service_account.alb-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "alb-sa-compute-viewer" {
  folder_id = local.network_folder_id
  role      = "compute.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.alb-sa.id}"
}

resource "yandex_iam_service_account_key" "alb-sa-key" {
  service_account_id = yandex_iam_service_account.alb-sa.id
  output_to_lockbox {
    entry_for_private_key = "key"
    secret_id             = yandex_lockbox_secret.alb.id
  }
}

// k8s
resource "yandex_iam_service_account" "k8s-sa" {
  name      = "k8s-sa"
  folder_id = local.sa_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-sa-logging-writer" {
  folder_id = local.logging_folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-sa-cluster-agent" {
  folder_id = local.network_folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-sa-public-admin" {
  folder_id = local.network_folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-sa-load-balancer-admin" {
  folder_id = local.network_folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

// container registry
resource "yandex_iam_service_account" "ai-radio-container-registry-sa" {
  name      = "reg-sa"
  folder_id = local.sa_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-crsa-images-puller" {
  folder_id = local.registry_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-container-registry-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-crsa-images-pusher" {
  folder_id = local.registry_folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-container-registry-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-crsa-images-create" {
  folder_id = local.registry_folder_id
  role      = "container-registry.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-container-registry-sa.id}"
}

resource "yandex_iam_service_account_key" "ai-radio-crsa-key" {
  service_account_id = yandex_iam_service_account.ai-radio-container-registry-sa.id
  output_to_lockbox {
    entry_for_private_key = "key"
    secret_id             = yandex_lockbox_secret.docker.id
  }
}

// object storage and sqs
resource "yandex_iam_service_account" "aws-sa" {
  folder_id   = local.sa_folder_id
  name        = "aws-sa"
  description = "AWS-like service account for ai-radio.ru"
}

resource "yandex_resourcemanager_folder_iam_member" "aws-sa-ymq-writer" {
  folder_id = local.sa_folder_id
  role      = "ymq.writer"
  member    = "serviceAccount:${yandex_iam_service_account.aws-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "aws-sa-ymq-reader" {
  folder_id = local.sa_folder_id
  role      = "ymq.reader"
  member    = "serviceAccount:${yandex_iam_service_account.aws-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "aws-sa-os-editor" {
  folder_id = local.storage_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.aws-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "aws-sa-static-key" {
  service_account_id = yandex_iam_service_account.aws-sa.id
  output_to_lockbox {
    entry_for_access_key = "key_id"
    entry_for_secret_key = "key"
    secret_id            = yandex_lockbox_secret.aws.id
  }
}

// speech kit tts
resource "yandex_iam_service_account" "tts-sa" {
  folder_id   = local.sa_folder_id
  name        = "tts-sa"
  description = "tts service account for ai-radio.ru"
}

resource "yandex_resourcemanager_cloud_iam_member" "tts-sa-tts-user" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio.id
  role     = "ai.speechkit-tts.user"
  member   = "serviceAccount:${yandex_iam_service_account.tts-sa.id}"
}

resource "yandex_iam_service_account_api_key" "tts-sa-api-key" {
  service_account_id = yandex_iam_service_account.tts-sa.id
  scopes             = ["yc.ai.speechkitTts.execute"]
  output_to_lockbox {
    entry_for_secret_key = "key"
    secret_id            = yandex_lockbox_secret.tts.id
  }
}

// serverless function invoker
resource "yandex_iam_service_account" "func-sa" {
  folder_id   = local.sa_folder_id
  name        = "func-sa"
  description = "serverless function invoker service account for ai-radio.ru"
}

resource "yandex_resourcemanager_cloud_iam_member" "func-sa-functionInvoker" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio.id
  role     = "functions.functionInvoker"
  member   = "serviceAccount:${yandex_iam_service_account.func-sa.id}"
}

resource "yandex_resourcemanager_cloud_iam_member" "func-sa-lockbox-payloadViewer" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio.id
  role     = "lockbox.payloadViewer"
  member   = "serviceAccount:${yandex_iam_service_account.func-sa.id}"
}