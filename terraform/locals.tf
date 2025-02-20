locals {
  sa_folder_id       = yandex_resourcemanager_folder.sa.id
  storage_folder_id  = yandex_resourcemanager_folder.storage.id
  network_folder_id  = yandex_resourcemanager_folder.network.id
  logging_folder_id  = yandex_resourcemanager_folder.logs.id
  secrets_folder_id  = yandex_resourcemanager_folder.secrets.id
  registry_folder_id = yandex_resourcemanager_folder.registry.id
}
