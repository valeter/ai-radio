resource "yandex_dns_zone" "ai-radio-zone" {
  name        = "ai-radio-zone"
  description = "dns zone"

  zone   = "ai-radio.ru."
  public = true

  deletion_protection = true
}

resource "yandex_dns_recordset" "ai-radio-a-1" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "@"
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.ai-radio-gateway-ip.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "ai-radio-a-2" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "*"
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.ai-radio-gateway-ip.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "ai-radio-aname-1" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "www"
  type    = "ANAME"
  ttl     = 600
  data    = ["ai-radio.ru"]
}

resource "yandex_dns_recordset" "ai-radio-txt-1" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "@"
  type    = "TXT"
  ttl     = 600
  data    = ["${var.dns_verification_key}"]
}
