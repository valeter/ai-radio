resource "yandex_iam_service_account" "ai-radio-base-sa" {
  name        = "ai-radio-base-sa"
  description = "Basic service account for ai-radio"
}

resource "yandex_iam_service_account_static_access_key" "ai-radio-static-key" {
  service_account_id = yandex_iam_service_account.ai-radio-base-sa.id
}

output "ai-radio-base-sa-id" {
  value = yandex_iam_service_account.ai-radio-base-sa.id
}
