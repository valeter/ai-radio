// container registry
resource "yandex_iam_service_account" "container_registry_sa" {
  name      = "ai-radio-registry-sa"
  folder_id = local.sa_folder_id
}
resource "yandex_resourcemanager_folder_iam_member" "container_registry_sa_images_puller" {
  folder_id = local.sa_folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.container_registry_sa.id}"
}

// object storage and sqs
resource "yandex_iam_service_account" "aws_sa" {
  folder_id   = local.sa_folder_id
  name        = "aws_sa"
  description = "AWS-like service account for ai-radio.ru"
}

resource "yandex_resourcemanager_folder_iam_member" "aws_sa_ymq_writer" {
  folder_id = local.sa_folder_id
  role      = "ymq.writer"
  member    = "serviceAccount:${yandex_iam_service_account.aws_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "aws_sa_ymq_reader" {
  folder_id = local.sa_folder_id
  role      = "ymq.reader"
  member    = "serviceAccount:${yandex_iam_service_account.aws_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "aws_sa_os_uploader" {
  folder_id = local.sa_folder_id
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.aws_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "aws_sa_static_key" {
  service_account_id = yandex_iam_service_account.aws_sa.id
  output_to_lockbox {
    entry_for_access_key = "ACCESS_KEY"
    entry_for_secret_key = "SECRET_KEY"
    secret_id            = yandex_lockbox_secret.aws.id
  }
}

// speech kit tts
resource "yandex_iam_service_account" "tts_sa" {
  folder_id   = local.sa_folder_id
  name        = "tts_sa"
  description = "tts service account for ai-radio.ru"
}

resource "yandex_resourcemanager_folder_iam_member" "tts_sa_tts_user" {
  folder_id = local.sa_folder_id
  role      = "ai.speechkit-tts.user"
  member    = "serviceAccount:${yandex_iam_service_account.tts_sa.id}"
}

resource "yandex_iam_service_account_api_key" "tts_sa_api_key" {
  service_account_id = yandex_iam_service_account.tts_sa.id
  scopes              = ["yc.ai.speechkitTts.execute"]
  output_to_lockbox {
    entry_for_secret_key = "SECRET_KEY"
    secret_id            = yandex_lockbox_secret.tts.id
  }
}
