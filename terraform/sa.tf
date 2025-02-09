resource "yandex_iam_service_account" "ai-radio-base-sa" {
  name        = "ai-radio-base-sa"
  description = "Basic service account for ai-radio"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-base-sa-storage-editor" {
  role   = "storage.editor"
  member = "serviceAccount:${yandex_iam_service_account.ai-radio-base-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ai-radio-base-sa-gw-editor" {
  role   = "api-gateway.editor"
  member = "serviceAccount:${yandex_iam_service_account.ai-radio-base-sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "ai-radio-static-key" {
  service_account_id = yandex_iam_service_account.ai-radio-base-sa.id
}

output "ai-radio-base-sa-id" {
  value = yandex_iam_service_account.ai-radio-base-sa.id
}
