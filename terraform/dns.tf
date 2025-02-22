resource "yandex_dns_zone" "ai-radio-zone" {
  name        = "ai-radio-zone"
  description = "dns zone"

  zone   = "ai-radio.ru."
  public = true

  folder_id = local.network_folder_id
}

resource "yandex_dns_recordset" "ai-radio-aname-root" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "@"
  type    = "ANAME"
  ttl     = 600
  data    = [yandex_api_gateway.static-gateway.domain]
}

resource "yandex_dns_recordset" "ai-radio-aname-www" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "www.ai-radio.ru."
  type    = "ANAME"
  ttl     = 600
  data    = [yandex_api_gateway.static-gateway.domain]
}

resource "yandex_dns_recordset" "ai-radio-a-stream" {
  zone_id = yandex_dns_zone.ai-radio-zone.id
  name    = "stream.ai-radio.ru."
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.ai-radio-stream-ip.external_ipv4_address[0].address]
}
