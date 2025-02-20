resource "yandex_resourcemanager_cloud" "ai-radio-prod" {
  organization_id = var.organization_id
  name            = "ai-radio-prod"
}

resource "yandex_resourcemanager_cloud_iam_member" "network_admin" {
  role     = "admin"
  member   = "serviceAccount:${var.service_account_id}"
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
}

resource "yandex_resourcemanager_folder" "network" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "network"
}

resource "yandex_resourcemanager_folder_iam_member" "network_admin" {
  folder_id = yandex_resourcemanager_folder.network.id
  role      = "admin"
  member    = "serviceAccount:${var.service_account_id}"
}

resource "yandex_resourcemanager_folder" "logs" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "logs"
}

resource "yandex_resourcemanager_folder_iam_member" "logs_admin" {
  folder_id = yandex_resourcemanager_folder.logs.id
  role      = "admin"
  member    = "serviceAccount:${var.service_account_id}"
}

resource "yandex_resourcemanager_folder" "sa" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_admin" {
  folder_id = yandex_resourcemanager_folder.sa.id
  role      = "admin"
  member    = "serviceAccount:${var.service_account_id}"
}

resource "yandex_resourcemanager_folder" "secrets" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "secrets"
}

resource "yandex_resourcemanager_folder_iam_member" "secrets_admin" {
  folder_id = yandex_resourcemanager_folder.secrets.id
  role      = "admin"
  member    = "serviceAccount:${var.service_account_id}"
}

resource "yandex_resourcemanager_folder" "storage" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "storage"
}

resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = yandex_resourcemanager_folder.storage.id
  role      = "admin"
  member    = "serviceAccount:${var.service_account_id}"
}

resource "yandex_resourcemanager_folder" "registry" {
  cloud_id = yandex_resourcemanager_cloud.ai-radio-prod.id
  name     = "registry"
}

resource "yandex_resourcemanager_folder_iam_member" "registry_admin" {
  folder_id = yandex_resourcemanager_folder.registry.id
  role      = "admin"
  member    = "serviceAccount:${var.service_account_id}"
}