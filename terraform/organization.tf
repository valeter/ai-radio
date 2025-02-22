// ai_radio_dev
resource "yandex_organizationmanager_group" "ai-radio-dev" {
  name            = "ai-radio-dev"
  description     = "ai-radio.ru developers"
  organization_id = var.organization_id
}

resource "yandex_organizationmanager_group_membership" "ai-radio-dev-membership" {
  group_id = yandex_organizationmanager_group.ai-radio-dev.id
  members  = var.developers
}

resource "yandex_organizationmanager_organization_iam_member" "ai-radio-dev-auditor" {
  organization_id = var.organization_id
  role            = "auditor"
  member          = "group:${yandex_organizationmanager_group.ai-radio-dev.id}"
}

resource "yandex_organizationmanager_organization_iam_member" "ai-radio-dev-logging-reader" {
  organization_id = var.organization_id
  role            = "logging.reader"
  member          = "group:${yandex_organizationmanager_group.ai-radio-dev.id}"
}

resource "yandex_organizationmanager_organization_iam_member" "ai-radio-dev-monitoring-viewer" {
  organization_id = var.organization_id
  role            = "monitoring.viewer"
  member          = "group:${yandex_organizationmanager_group.ai-radio-dev.id}"
}

// ai_radio_ops
resource "yandex_organizationmanager_group" "ai-radio-ops" {
  name            = "ai-radio-ops"
  description     = "ai-radio.ru operations"
  organization_id = var.organization_id
}

resource "yandex_organizationmanager_group_membership" "ai-radio-ops-membership" {
  group_id = yandex_organizationmanager_group.ai-radio-ops.id
  members  = var.operations
}

resource "yandex_organizationmanager_organization_iam_member" "ai-radio-ops-viewer" {
  organization_id = var.organization_id
  role            = "viewer"
  member          = "group:${yandex_organizationmanager_group.ai-radio-ops.id}"
}

resource "yandex_organizationmanager_organization_iam_member" "ai-radio-ops-monitoring-editor" {
  organization_id = var.organization_id
  role            = "monitoring.editor"
  member          = "group:${yandex_organizationmanager_group.ai-radio-ops.id}"
}