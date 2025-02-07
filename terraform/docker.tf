resource "yandex_container_registry" "ai-radio-registry" {
  name      = "ai-radio-registry"
  folder_id = "b1g2inpl68al98r9ock7"
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.ai-radio-registry
  role        = "container-registry.images.puller"

  members = [
    "system:group:organization:bpf7g9i7n7ntnksbdvlr:users",
  ]
}

resource "yandex_container_repository" "caster" {
  name = "${yandex_container_registry.ai-radio-registry.id}/caster"
}
