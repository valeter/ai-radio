resource "yandex_storage_bucket" "ai-radio-website-bucket" {
  folder_id  = var.folder_id
  acl        = "public-read"
  bucket     = "ai-radio-website"
  access_key = yandex_iam_service_account_static_access_key.ai-radio-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ai-radio-static-key.secret_key
}

resource "yandex_storage_bucket" "ai-radio-music-bucket" {
  folder_id  = var.folder_id
  bucket     = "ai-radio-music"
  access_key = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.secret_key
}

output "ai-radio-website-bucket-name" {
  value     = yandex_storage_bucket.ai-radio-website-bucket.bucket
  sensitive = true
}

output "ai-radio-music-bucket-name" {
  value     = yandex_storage_bucket.ai-radio-music-bucket.bucket
  sensitive = true
}
