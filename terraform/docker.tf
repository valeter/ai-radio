resource "yandex_container_registry" "ai-radio-registry" {
  name      = "ai-radio-registry"
  folder_id = var.folder_id
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.ai-radio-registry.id
  role        = "container-registry.images.puller"

  members = [
    "system:group:organization:${var.organization_id}:users",
  ]
}

resource "yandex_container_repository" "caster" {
  name = "${yandex_container_registry.ai-radio-registry.id}/caster"
}
