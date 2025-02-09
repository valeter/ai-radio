resource "yandex_storage_bucket" "ai-radio-images-bucket" {
  bucket     = "ai-radio-images"
  access_key = yandex_iam_service_account_static_access_key.ai-radio-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ai-radio-static-key.secret_key
}

resource "yandex_storage_bucket" "ai-radio-website-bucket" {
  bucket     = "ai-radio-website"
  access_key = yandex_iam_service_account_static_access_key.ai-radio-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ai-radio-static-key.secret_key
}

output "ai-radio-images-bucket-name" {
  value = yandex_storage_bucket.ai-radio-images-bucket.bucket
}

output "ai-radio-website-bucket-name" {
  value = yandex_storage_bucket.ai-radio-website-bucket.bucket
}
