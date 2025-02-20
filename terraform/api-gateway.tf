resource "yandex_api_gateway" "static_gateway" {
  folder_id   = local.network_folder_id
  name        = "ai_radio_static_gateway"
  description = "gateway for ai-radio.ru static website"
  spec        = file("../openapi/static.yaml")
  connectivity {
    network_id = yandex_vpc_network.network.id
  }
  custom_domains {
    fqdn           = "ai-radio.ru"
    certificate_id = data.yandex_cm_certificate.ai_radio_cert.id
  }
  log_options {
    log_group_id = yandex_logging_group.static_gateway_log.id
  }
  execution_timeout = "30"
}
