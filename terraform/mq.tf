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
  access_key                  = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[1].text_value
  secret_key                  = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[0].text_value
}

resource "yandex_message_queue" "ai_radio_voice_gen_dlq" {
  name                        = "ai_radio_voice_gen_dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  access_key                  = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[1].text_value
  secret_key                  = data.yandex_lockbox_secret_version.aws_sa_static_key_version.entries[0].text_value
}
