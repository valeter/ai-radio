resource "yandex_api_gateway" "ai-radio-static-gateway" {
  folder_id = var.folder_id
  name      = "ai-radio-static-gateway"
  spec = templatefile("../openapi/static.yaml", {
    container_id       = yandex_serverless_container.ai-radio-caster-container.id
    service_account_id = var.service_account_id
  })
  connectivity {
    network_id = module.yc-vpc.vpc_id
  }
  custom_domains {
    fqdn           = "ai-radio.ru"
    certificate_id = var.cert_id
  }
}
