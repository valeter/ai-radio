
### Network
resource "yandex_vpc_network" "ai-radio-network" {
  name      = "ai-radio-network"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "ai-radio-private-subnet-1" {
  name           = "ai-radio-private-subnet-1"
  v4_cidr_blocks = ["192.168.5.0/24"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.ai-radio-network.id
  folder_id      = var.folder_id
  route_table_id = yandex_vpc_route_table.ai-radio-route-table.id
}

resource "yandex_vpc_subnet" "ai-radio-private-subnet-2" {
  name           = "ai-radio-private-subnet-2"
  v4_cidr_blocks = ["192.168.15.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.ai-radio-network.id
  folder_id      = var.folder_id
  route_table_id = yandex_vpc_route_table.ai-radio-route-table.id
}

## Routes
resource "yandex_vpc_gateway" "ai-radio-egress_gateway" {
  name      = "ai-radio-egress-gateway"
  folder_id = var.folder_id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "ai-radio-route-table" {
  name       = "ai-radio-route-table"
  network_id = yandex_vpc_network.ai-radio-network.id
  folder_id  = var.folder_id

  dynamic "static_route" {
    for_each = yandex_vpc_gateway.ai-radio-egress_gateway
    content {
      destination_prefix = "0.0.0.0/0"
      gateway_id         = yandex_vpc_gateway.ai-radio-egress_gateway.id
    }
  }

}

## Default Security Group
resource "yandex_vpc_default_security_group" "default_sg" {
  network_id = yandex_vpc_network.ai-radio-network.id
  folder_id  = var.folder_id

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
    description    = "from gw"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 80
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
}
