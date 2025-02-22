resource "yandex_message_queue" "ai-radio-voice-gen" {
  name                       = "ai-radio-voice-gen.fifo"
  visibility_timeout_seconds = 600    // 10 min
  message_retention_seconds  = 345600 // 4 days
  max_message_size           = 262144 // 256 kb
  delay_seconds              = 0
  redrive_policy = jsonencode({
    deadLetterTargetArn = yandex_message_queue.ai-radio-voice-gen-dlq.arn
    maxReceiveCount     = 3
  })
  receive_wait_time_seconds   = 2
  fifo_queue                  = true
  content_based_deduplication = true
  access_key                  = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[1].text_value)
  secret_key                  = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[0].text_value)
}

resource "yandex_message_queue" "ai-radio-voice-gen-dlq" {
  name                        = "ai-radio-voice-gen-dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  access_key                  = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[1].text_value)
  secret_key                  = sensitive(data.yandex_lockbox_secret_version.aws-sa-static-key-version.entries[0].text_value)
}
