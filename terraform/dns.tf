resource "yandex_dns_zone" "ai-radio-zone" {
  name        = "ai-radio-zone"
  description = "dns zone"

  zone   = "ai-radio.ru."
  public = true

  deletion_protection = true
}

resource "yandex_dns_recordset" "ai-radio-aname-1" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "@"
  type    = "ANAME"
  ttl     = 600
  data    = [yandex_api_gateway.ai-radio-static-gateway.domain]
}

resource "yandex_dns_recordset" "ai-radio-txt-1" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "@"
  type    = "TXT"
  ttl     = 600
  data    = ["${var.dns_verification_key}"]
}
