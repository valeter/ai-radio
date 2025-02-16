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

resource "yandex_container_repository" "ai-radio-caster" {
  name = "${yandex_container_registry.ai-radio-registry.id}/ai-radio-caster"
}

output "ai-radio-caster-repository-name" {
  value     = "cr.yandex/${yandex_container_repository.ai-radio-caster.name}"
  sensitive = true
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

