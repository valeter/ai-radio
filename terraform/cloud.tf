// prod
resource "yandex_resourcemanager_cloud" "ai-radio" {
  organization_id = var.organization_id
  name            = "ai-radio"
}

resource "yandex_billing_cloud_binding" "ai-radio-prod-billing" {
  billing_account_id = var.billing_account_id
  cloud_id           = yandex_resourcemanager_cloud.ai-radio.id
}

resource "yandex_resourcemanager_folder" "network" {
  cloud_id   = yandex_resourcemanager_cloud.ai-radio.id
  name       = "network"
  depends_on = [yandex_billing_cloud_binding.ai-radio-prod-billing]
}

resource "yandex_resourcemanager_folder" "logs" {
  cloud_id   = yandex_resourcemanager_cloud.ai-radio.id
  name       = "logs"
  depends_on = [yandex_billing_cloud_binding.ai-radio-prod-billing]
}

resource "yandex_resourcemanager_folder" "sa" {
  cloud_id   = yandex_resourcemanager_cloud.ai-radio.id
  name       = "sa"
  depends_on = [yandex_billing_cloud_binding.ai-radio-prod-billing]
}

resource "yandex_resourcemanager_folder" "secrets" {
  cloud_id   = yandex_resourcemanager_cloud.ai-radio.id
  name       = "secrets"
  depends_on = [yandex_billing_cloud_binding.ai-radio-prod-billing]
}

resource "yandex_resourcemanager_folder" "storage" {
  cloud_id   = yandex_resourcemanager_cloud.ai-radio.id
  name       = "storage"
  depends_on = [yandex_billing_cloud_binding.ai-radio-prod-billing]
}

resource "yandex_resourcemanager_folder" "registry" {
  cloud_id   = yandex_resourcemanager_cloud.ai-radio.id
  name       = "registry"
  depends_on = [yandex_billing_cloud_binding.ai-radio-prod-billing]
}