// container registry
resource "yandex_iam_service_account" "ai-radio-container-registry-sa" {
  name      = "ai-radio-container-registry-sa"
  folder_id = local.sa_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-crsa-images-puller" {
  folder_id = local.registry_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-container-registry-sa.id}"
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
  cloud_id  = yandex_resourcemanager_cloud.ai-radio.id
  role      = "ai.speechkit-tts.user"
  member    = "serviceAccount:${yandex_iam_service_account.tts-sa.id}"
}

resource "yandex_iam_service_account_api_key" "tts-sa-api-key" {
  service_account_id = yandex_iam_service_account.tts-sa.id
  scopes             = ["yc.ai.speechkitTts.execute"]
  output_to_lockbox {
    entry_for_secret_key = "key"
    secret_id            = yandex_lockbox_secret.tts.id
  }
}