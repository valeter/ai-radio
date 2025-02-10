resource "yandex_compute_disk" "ai-radio-caster-disk" {
  name     = "ai-radio-caster-disk"
  type     = "network-ssd"
  zone     = "ru-central1-d"
  size     = "10"
  image_id = "fd86idv7gmqapoeiq5ld"
}

resource "yandex_compute_instance" "ai-radio-caster-vm" {
  name                      = "ai-radio-caster-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-d"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    disk_id = yandex_compute_disk.ai-radio-caster-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.ai-radio-private-subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${templatefile("user-data/cloud-init.yaml", {
      ssh_key = var.ssh_key_pub
    })}"
    ssh-keys = "valter:${var.ssh_key_pub}"
  }
}
