resource "yandex_iam_service_account" "ai-radio-base-sa" {
  name        = "ai-radio-base-sa"
  description = "Basic service account for ai-radio"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-base-sa-storage-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-base-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-base-sa-gw-editor" {
  folder_id = var.folder_id
  role      = "api-gateway.editor"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-base-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "ai-radio-static-key" {
  service_account_id = yandex_iam_service_account.ai-radio-base-sa.id
}

resource "yandex_iam_service_account" "ai-radio-mq-sa" {
  name        = "ai-radio-mq-sa"
  description = "MQ service account for ai-radio"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-mq-sa-ymq-writer" {
  folder_id = var.folder_id
  role      = "ymq.writer"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-mq-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-mq-sa-ymq-reader" {
  folder_id = var.folder_id
  role      = "ymq.reader"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-mq-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-mq-sa-os-uploader" {
  folder_id = var.folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-mq-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "ai-radio-mq-static-key" {
  service_account_id = yandex_iam_service_account.ai-radio-mq-sa.id
}

resource "yandex_iam_service_account" "ai-radio-tts-sa" {
  name        = "ai-radio-tts-sa"
  description = "tts service account for ai-radio"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-tts-sa-tts-user" {
  folder_id = var.folder_id
  role      = "ai.speechkit-tts.user"
  member    = "serviceAccount:${yandex_iam_service_account.ai-radio-tts-sa.id}"
}

resource "yandex_iam_service_account_api_key" "ai-radio-tts-sa-api-key" {
  service_account_id = yandex_iam_service_account.ai-radio-tts-sa.id
  scope              = "yc.ai.speechkitTts.execute"
}

output "ai-radio-base-sa-id" {
  value     = yandex_iam_service_account.ai-radio-base-sa.id
  sensitive = true
}

output "ai-radio-mq-sa-access-key" {
  value     = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.access_key
  sensitive = true
}

output "ai-radio-mq-sa-secret-key" {
  value     = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.secret_key
  sensitive = true
}

output "ai-radio-tts-sa-secret-key" {
  value     = yandex_iam_service_account_api_key.ai-radio-tts-sa-api-key.secret_key
  sensitive = true
}
