resource "yandex_cm_certificate" "ai-radio-cert" {
  folder_id = local.network_folder_id
  name      = "ai_radio_cert"
  domains   = ["ai-radio.ru"]
  managed {
    challenge_type = "DNS_TXT"
  }
}

resource "yandex_dns_recordset" "ai_radio_validation_record" {
  zone_id = yandex_dns_zone.ai_radio_zone.id
  name    = yandex_cm_certificate.ai-radio-cert.challenges[0].dns_name
  type    = yandex_cm_certificate.ai-radio-cert.challenges[0].dns_type
  data    = [yandex_cm_certificate.ai-radio-cert.challenges[0].dns_value]
  ttl     = 10
}

data "yandex_cm_certificate" "ai-radio-cert" {
  depends_on      = [yandex_dns_recordset.ai_radio_validation_record]
  certificate_id  = yandex_cm_certificate.ai-radio-cert.id
  wait_validation = true
}
