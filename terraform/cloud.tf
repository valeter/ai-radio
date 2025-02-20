resource "yandex_resourcemanager_cloud" "ai-radio-prod" {
  organization_id = var.organization_id
  name            = "ai-radio-prod"
}

resource "yandex_billing_cloud_binding" "ai-radio-prod-billing" {
  billing_account_id = var.billing_account_id
  cloud_id           = yandex_resourcemanager_cloud.ai-radio-prod.id
}

resource "yandex_resourcemanager_folder" "network" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "network"
}

resource "yandex_resourcemanager_folder" "logs" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "logs"
}

resource "yandex_resourcemanager_folder" "sa" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "sa"
}

resource "yandex_resourcemanager_folder" "secrets" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "secrets"
}

resource "yandex_resourcemanager_folder" "storage" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "storage"
}

resource "yandex_resourcemanager_folder" "registry" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "registry"
}