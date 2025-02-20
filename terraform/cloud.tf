resource "yandex_resourcemanager_cloud" "ai_radio_prod" {
  organization_id = var.organization_id
  name            = "ai_radio_prod"
}

resource "yandex_resourcemanager_folder" "network" {
  cloud_id = yandex_resourcemanager_cloud.ai_radio_prod.id
  name     = "network"
}

resource "yandex_resourcemanager_folder" "logs" {
  cloud_id = yandex_resourcemanager_cloud.ai_radio_prod.id
  name     = "logs"
}

resource "yandex_resourcemanager_folder" "sa" {
  cloud_id = yandex_resourcemanager_cloud.ai_radio_prod.id
  name     = "sa"
}

resource "yandex_resourcemanager_folder" "secrets" {
  cloud_id = yandex_resourcemanager_cloud.ai_radio_prod.id
  name     = "secrets"
}

resource "yandex_resourcemanager_folder" "storage" {
  cloud_id = yandex_resourcemanager_cloud.ai_radio_prod.id
  name     = "storage"
}

resource "yandex_resourcemanager_folder" "registry" {
  cloud_id = yandex_resourcemanager_cloud.ai_radio_prod.id
  name     = "registry"
}