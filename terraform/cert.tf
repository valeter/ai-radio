resource "yandex_cm_certificate" "ai-radio-cert" {
  folder_id = local.network_folder_id
  name      = "ai-radio-cert"
  domains   = ["ai-radio.ru"]
  managed {
    challenge_type = "DNS_TXT"
  }
}

resource "yandex_dns_recordset" "ai-radio-validation-record" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = yandex_cm_certificate.ai-radio-cert.challenges[0].dns_name
  type    = yandex_cm_certificate.ai-radio-cert.challenges[0].dns_type
  data    = [yandex_cm_certificate.ai-radio-cert.challenges[0].dns_value]
  ttl     = 10
}

data "yandex_cm_certificate" "ai-radio-cert" {
  depends_on      = [yandex_dns_recordset.ai-radio-validation-record]
  certificate_id  = yandex_cm_certificate.ai-radio-cert.id
  wait_validation = true
}

data "yandex_cm_certificate_content" "ai-radio-cert-content" {
  certificate_id = yandex_cm_certificate.ai-radio-cert.id
}

output "ai_radio_cert_key" {
  value     = data.yandex_cm_certificate_content.ai-radio-cert-content.private_key
  sensitive = true
}

output "ai_radio_cert_crt" {
  value     = data.yandex_cm_certificate_content.ai-radio-cert-content.certificates
  sensitive = true
}