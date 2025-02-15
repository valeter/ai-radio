resource "yandex_message_queue" "ai_radio_voice_gen" {
  name                       = "ai_radio_voice_gen.fifo"
  visibility_timeout_seconds = 600    // 10 min
  message_retention_seconds  = 345600 // 4 days
  max_message_size           = 262144 // 256 kb
  delay_seconds              = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = yandex_message_queue.ai_radio_voice_gen_dlq.arn
    maxReceiveCount     = 3
  })
  receive_wait_time_seconds   = 2
  fifo_queue                  = true
  content_based_deduplication = true
  access_key                  = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.access_key
  secret_key                  = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.secret_key
}

resource "yandex_message_queue" "ai_radio_voice_gen_dlq" {
  name                        = "ai_radio_voice_gen_dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  access_key                  = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.access_key
  secret_key                  = yandex_iam_service_account_static_access_key.ai-radio-mq-static-key.secret_key
}
