resource "yandex_storage_bucket" "ai-radio-website-bucket" {
  folder_id  = local.storage_folder_id
  acl        = "public-read"
  bucket     = "ai-radio-website"
  access_key = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[1].text_value)
  secret_key = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[0].text_value)
  max_size   = 10737418240
}

resource "yandex_storage_bucket" "ai-radio-music-bucket" {
  folder_id  = local.storage_folder_id
  bucket     = "ai-radio-music"
  access_key = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[1].text_value)
  secret_key = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[0].text_value)
  max_size   = 107374182400
}

resource "yandex_storage_bucket" "ai-radio-functions-bucket" {
  folder_id  = local.storage_folder_id
  bucket     = "ai-radio-functions"
  access_key = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[1].text_value)
  secret_key = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[0].text_value)
  max_size   = 10737418240
}