resource "yandex_storage_bucket" "ai_radio_website_bucket" {
  folder_id  = local.storage_folder_id
  acl        = "public-read"
  bucket     = "ai_radio_website"
  access_key = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[1].text_value
  secret_key = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[0].text_value
}

resource "yandex_storage_bucket" "ai_radio_music_bucket" {
  folder_id  = local.storage_folder_id
  bucket     = "ai_radio_music"
  access_key = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[1].text_value
  secret_key = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[0].text_value
}
