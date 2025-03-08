resource "yandex_function" "speech-generator" {
  count = var.speech_generator_version == null ? 0 : 1

  folder_id          = local.functions_folder_id
  name               = "speech-generator"
  description        = "listens to mq message for tts generation, stores result to object storage"
  user_hash          = var.speech_generator_version
  runtime            = "golang121"
  entrypoint         = "HandleRequest"
  memory             = "128"
  execution_timeout  = "60"
  service_account_id = var.service_account_id
  environment = {
    "FOLDER_ID" = local.functions_folder_id
    "QUEUE_URL" = data.yandex_message_queue.ai-radio-voice-gen.url
  }
  secrets {
    id                   = yandex_lockbox_secret.aws.id
    version_id           = data.yandex_lockbox_secret_version.aws-sa-static-key-version.id
    key                  = "key_id"
    environment_variable = "AWS_ACCESS_KEY_ID"
  }
  secrets {
    id                   = yandex_lockbox_secret.aws.id
    version_id           = data.yandex_lockbox_secret_version.aws-sa-static-key-version.id
    key                  = "key"
    environment_variable = "AWS_SECRET_ACCESS_KEY"
  }
  package {
    bucket_name = yandex_storage_bucket.ai-radio-functions-bucket.bucket
    object_name = var.speech_generator_version
  }
  async_invocation {
    retries_count       = "2"
    service_account_id = yandex_iam_service_account.func-sa.id
  }
  log_options {
    log_group_id = yandex_logging_group.speech-generator-log.id
    min_level    = "DEBUG"
  }
  concurrency = 1
}

resource "yandex_function_trigger" "speech-generator-mq-trigger" {
  count = var.speech_generator_version == null ? 0 : 1

  folder_id = local.functions_folder_id
  name      = "speech-generator-mq-trigger"

  function {
    id                 = yandex_function.speech-generator[0].id
    service_account_id = yandex_iam_service_account.func-sa.id
  }

  message_queue {
    queue_id           = yandex_message_queue.ai-radio-voice-gen.id
    service_account_id = yandex_iam_service_account.func-sa.id
    batch_size         = 10
    batch_cutoff       = 5
  }
}