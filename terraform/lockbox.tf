// container registry
resource "yandex_lockbox_secret" "alb" {
  folder_id = local.secrets_folder_id
  name      = "alb"
}

resource "yandex_lockbox_secret_iam_binding" "alb-viewer" {
  secret_id = yandex_lockbox_secret.alb.id
  role      = "viewer"
  members = [
    "group:${yandex_organizationmanager_group.ai-radio-ops.id}",
  ]
}

// container registry
resource "yandex_lockbox_secret" "docker" {
  folder_id = local.secrets_folder_id
  name      = "docker"
}

resource "yandex_lockbox_secret_iam_binding" "docker-viewer" {
  secret_id = yandex_lockbox_secret.docker.id
  role      = "viewer"
  members = [
    "group:${yandex_organizationmanager_group.ai-radio-dev.id}",
  ]
}

// object storage and message queue
resource "yandex_lockbox_secret" "aws" {
  folder_id = local.secrets_folder_id
  name      = "aws"
}

resource "yandex_lockbox_secret_iam_binding" "aws-viewer" {
  secret_id = yandex_lockbox_secret.aws.id
  role      = "viewer"
  members = [
    "group:${yandex_organizationmanager_group.ai-radio-ops.id}",
  ]
}

data "yandex_lockbox_secret_version" "aws-sa-static-key-version" {
  secret_id  = yandex_lockbox_secret.aws.id
  version_id = yandex_iam_service_account_static_access_key.aws-sa-static-key.output_to_lockbox_version_id
  depends_on = [yandex_lockbox_secret.aws]
}

// speech kit
resource "yandex_lockbox_secret" "tts" {
  folder_id = local.secrets_folder_id
  name      = "tts"
}

resource "yandex_lockbox_secret_iam_binding" "tts-viewer" {
  secret_id = yandex_lockbox_secret.tts.id
  role      = "viewer"
  members = [
    "group:${yandex_organizationmanager_group.ai-radio-ops.id}",
  ]
}

data "yandex_lockbox_secret_version" "tts-sa-static-key-version" {
  secret_id  = yandex_lockbox_secret.tts.id
  version_id = yandex_iam_service_account_api_key.tts-sa-api-key.output_to_lockbox_version_id
  depends_on = [yandex_lockbox_secret.tts]
}

// outputs
output "aws_access_key" {
  value     = data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[1].text_value
  sensitive = true
}

output "aws_secret_key" {
  value     = data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[0].text_value
  sensitive = true
}

output "tts_key" {
  value     = data.yandex_lockbox_secret_version.tts-sa-static-key-version.entries[0].text_value
  sensitive = true
}