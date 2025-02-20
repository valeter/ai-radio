// object storage and message queue
resource "yandex_lockbox_secret" "aws" {
  folder_id = local.secrets_folder_id
  name      = "ai_radio_music"
}

resource "yandex_lockbox_secret_iam_binding" "aws_viewer" {
  secret_id = yandex_lockbox_secret.aws.id
  role      = "viewer"
  members = [
    "group:${yandex_organizationmanager_group.ai_radio_ops.id}",
  ]
}

data "yandex_lockbox_secret_version" "aws_sa_static_key_version" {
  secret_id  = yandex_lockbox_secret.aws.id
  version_id = yandex_iam_service_account_static_access_key.aws_sa_static_key.output_to_lockbox_version_id
  depends_on = [
    yandex_lockbox_secret.aws
  ]
}

// speech kit
resource "yandex_lockbox_secret" "tts" {
  folder_id = local.secrets_folder_id
  name      = "tts"
}

resource "yandex_lockbox_secret_iam_binding" "tts_viewer" {
  secret_id = yandex_lockbox_secret.tts.id
  role      = "viewer"
  members = [
    "group:${yandex_organizationmanager_group.ai_radio_ops.id}",
  ]
}

data "yandex_lockbox_secret_version" "tts_sa_static_key_version" {
  secret_id  = yandex_lockbox_secret.tts.id
  version_id = yandex_iam_service_account_api_key.tts_sa_api_key.output_to_lockbox_version_id
  depends_on = [
    yandex_lockbox_secret.tts
  ]
}


// outputs
output "aws_access_key" {
  value     = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[1].text_value
  sensitive = true
}

output "aws_secret_key" {
  value     = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[0].text_value
  sensitive = true
}

output "tts_key" {
  value     = data.yandex_lockbox_secret_version.tts_sa_static_key_version.entries[0].text_value
  sensitive = true
}
