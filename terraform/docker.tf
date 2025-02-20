resource "yandex_container_registry" "ai_radio_registry" {
  name      = "ai_radio_registry"
  folder_id = local.registry_folder_id
}

resource "yandex_container_repository" "ai_radio_caster" {
  name = "${yandex_container_registry.ai_radio_registry.id}/ai_radio_caster"
}

resource "yandex_container_registry_iam_binding" "ai_radio_caster_puller" {
  registry_id = yandex_container_repository.ai_radio_caster.id
  role        = "container-registry.images.puller"
  members = [
    "group:${yandex_organizationmanager_group.ai_radio_dev.id}",
  ]
}

resource "yandex_container_repository_lifecycle_policy" "ai_radio_caster_policy" {
  name          = "ai_radio_caster_policy"
  status        = "active"
  repository_id = yandex_container_repository.ai_radio_caster.id

  rule {
    description  = "remove old versions"
    untagged     = true
    tag_regexp   = ".*"
    retained_top = 1
  }
}
