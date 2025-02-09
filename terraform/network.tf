
module "yc-vpc" {
  source              = "github.com/terraform-yc-modules/terraform-yc-vpc.git"
  network_name        = "ai-radio-network"
  network_description = "Basic network for ai-radio app"
  create_nat_gw       = true
  create_sg           = true
  private_subnets = [
    {
      name           = "subnet-1"
      zone           = "ru-central1-d"
      v4_cidr_blocks = ["192.168.5.0/24"]
    },
    {
      name           = "subnet-2"
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["192.168.15.0/24"]
    }
  ]
}

resource "yandex_vpc_address" "ai-radio-gateway-ip" {
  name = "ai-radio-gateway-ip"

  external_ipv4_address {
    zone_id                  = "ru-central1-d"
    ddos_protection_provider = "qrator"
  }
}
