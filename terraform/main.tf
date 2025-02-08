terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-d"
}

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

resource "yandex_vpc_address" "ai-cloud-gateway-ip" {
  name = "ai-cloud-gateway-ip"

  external_ipv4_address {
    zone_id                  = "ru-central1-d"
    ddos_protection_provider = "qrator"
  }
}

resource "yandex_dns_zone" "ai-cloud-zone" {
  name        = "ai-cloud-zone"
  description = "dns zone"

  zone             = "ai-cloud.ru."
  public           = true
  private_networks = ["${module.yc-vpc.vpc_id}"]

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

resource "yandex_dns_recordset" "ai-cloud-a-3" {
  zone_id = yandex_dns_zone.ai-cloud-zone.id
  name    = "www"
  type    = "ANAME"
  ttl     = 600
  data    = ["ai-cloud.ru"]
}
