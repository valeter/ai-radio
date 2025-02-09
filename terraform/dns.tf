resource "yandex_dns_zone" "ai-cloud-zone" {
  name        = "ai-cloud-zone"
  description = "dns zone"

  zone   = "ai-cloud.ru."
  public = true

  deletion_protection = true
}

resource "yandex_dns_recordset" "ai-cloud-a-1" {
  zone_id = yandex_dns_zone.ai-cloud-zone.id
  name    = "@"
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.ai-cloud-gateway-ip.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "ai-cloud-a-2" {
  zone_id = yandex_dns_zone.ai-cloud-zone.id
  name    = "*"
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.ai-cloud-gateway-ip.external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "ai-cloud-aname-1" {
  zone_id = yandex_dns_zone.ai-cloud-zone.id
  name    = "www"
  type    = "ANAME"
  ttl     = 600
  data    = ["ai-cloud.ru"]
}

resource "yandex_dns_recordset" "ai-cloud-txt-1" {
  zone_id = yandex_dns_zone.ai-cloud-zone.id
  name    = "@"
  type    = "TXT"
  ttl     = 600
  data    = ["${var.dns_verification_key}"]
}
