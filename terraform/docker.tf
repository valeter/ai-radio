resource "yandex_container_registry" "ai-radio-registry" {
  name      = "ai-radio-registry"
  folder_id = local.registry_folder_id
}

resource "yandex_container_repository" "ai-radio-caster" {
  name = "${yandex_container_registry.ai-radio-registry.id}/ai-radio-caster"
}

resource "yandex_container_repository_iam_binding" "ai-radio-caster-puller" {
  repository_id = yandex_container_repository.ai-radio-caster.id
  role          = "container-registry.images.puller"
  members = [
    "group:${yandex_organizationmanager_group.ai-radio-dev.id}",
  ]
}

resource "yandex_container_repository_lifecycle_policy" "ai-radio-caster-policy" {
  name          = "ai-radio-caster-policy"
  status        = "active"
  repository_id = yandex_container_repository.ai-radio-caster.id

  rule {
    description  = "remove old versions"
    untagged     = true
    tag_regexp   = ".*"
    retained_top = 1
  }
}
