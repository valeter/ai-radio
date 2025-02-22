resource "yandex_vpc_network" "default-network" {
  name      = "default-network"
  folder_id = local.network_folder_id
}

resource "yandex_vpc_subnet" "private-subnet-d" {
  name           = "private-subnet-d"
  v4_cidr_blocks = ["192.168.5.0/24"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.default-network.id
  folder_id      = local.network_folder_id
  route_table_id = yandex_vpc_route_table.route-table.id
}

resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "private-subnet-a"
  v4_cidr_blocks = ["192.168.15.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default-network.id
  folder_id      = local.network_folder_id
  route_table_id = yandex_vpc_route_table.route-table.id
}

resource "yandex_vpc_gateway" "egress-gateway" {
  name      = "egress-gateway"
  folder_id = local.network_folder_id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route-table" {
  name       = "route_table"
  network_id = yandex_vpc_network.default-network.id
  folder_id  = local.network_folder_id

  dynamic "static_route" {
    for_each = yandex_vpc_gateway.egress-gateway
    content {
      destination_prefix = "0.0.0.0/0"
      gateway_id         = yandex_vpc_gateway.egress-gateway.id
    }
  }
}

resource "yandex_vpc_default_security_group" "default-sg" {
  network_id = yandex_vpc_network.default-network.id
  folder_id  = local.network_folder_id

  ingress {
    protocol          = "ANY"
    description       = "Communication inside this SG"
    predefined_target = "self_security_group"
  }

  ingress {
    protocol       = "ANY"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "ANY"
    description    = "RDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3389
  }

  ingress {
    protocol       = "ICMP"
    description    = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol       = "TCP"
    description    = "https from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 443
  }

  ingress {
    protocol          = "TCP"
    description       = "NLB health check"
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    description    = "To internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "healthchecks"
    predefined_target = "loadbalancer_healthchecks"
    port              = 30080
  }
}

resource "yandex_vpc_address" "ai-radio-stream-ip" {
  folder_id = local.network_folder_id
  name      = "ai-radio-stream-ip"
  external_ipv4_address {
    zone_id                  = "ru-central1-d"
    ddos_protection_provider = "qrator"
  }
}

output "ai_radio_stream_ip" {
  description = "stream.ai-radio.ru ip"
  value       = yandex_vpc_address.ai-radio-stream-ip.external_ipv4_address[0].address
}
