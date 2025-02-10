resource "yandex_api_gateway" "ai-radio-static-gateway" {
  folder_id = var.folder_id
  name      = "ai-radio-static-gateway"
  spec = templatefile("../openapi/static.yaml", {
    vm_ip = yandex_compute_instance.ai-radio-caster-vm.network_interface.0.nat_ip_address
  })
  #spec = file("../openapi/static.yaml")
  connectivity {
    network_id = yandex_vpc_network.ai-radio-network.id
  }
  custom_domains {
    fqdn           = "ai-radio.ru"
    certificate_id = var.cert_id
  }
}
