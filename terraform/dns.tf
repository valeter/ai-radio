resource "yandex_dns_zone" "ai_radio_zone" {
  name        = "ai-radio-zone"
  description = "dns zone"

  zone   = "ai-radio.ru."
  public = true

  folder_id = local.network_folder_id
}

resource "yandex_dns_recordset" "ai_radio_aname_root" {
  zone_id = yandex_dns_zone.ai_radio_zone.id
  name    = "@"
  type    = "ANAME"
  ttl     = 600
  data    = [yandex_api_gateway.static_gateway.domain]
}

resource "yandex_dns_recordset" "ai_radio_aname_www" {
  zone_id = yandex_dns_zone.ai_radio_zone.id
  name    = "www.ai-radio.ru."
  type    = "ANAME"
  ttl     = 600
  data    = [yandex_api_gateway.static_gateway.domain]
}

resource "yandex_dns_recordset" "ai_radio_a_stream" {
  zone_id = yandex_dns_zone.ai_radio_zone.id
  name    = "stream.ai-radio.ru."
  type    = "A"
  ttl     = 600
  data    = [yandex_vpc_address.ai_radio_stream_ip.external_ipv4_address[0].address]
}
