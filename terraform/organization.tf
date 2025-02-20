// ai_radio_dev
resource "yandex_organizationmanager_group" "ai_radio_dev" {
  name            = "ai_radio_dev"
  description     = "ai-radio.ru developers"
  organization_id = var.organization_id
}

resource "yandex_organizationmanager_group_membership" "ai_radio_dev_membership" {
  group_id = yandex_organizationmanager_group.ai_radio_dev.id
  members  = var.developers
}

resource "yandex_organizationmanager_organization_iam_member" "ai_radio_dev_auditor" {
  organization_id = var.organization_id
  role            = "auditor"
  member          = "group:${yandex_organizationmanager_group.ai_radio_dev.id}"
}

resource "yandex_organizationmanager_organization_iam_member" "ai_radio_dev_logging_reader" {
  organization_id = var.organization_id
  role            = "logging.reader"
  member          = "group:${yandex_organizationmanager_group.ai_radio_dev.id}"
}

resource "yandex_organizationmanager_organization_iam_member" "ai_radio_dev_monitoring_viewer" {
  organization_id = var.organization_id
  role            = "monitoring.viewer"
  member          = "group:${yandex_organizationmanager_group.ai_radio_dev.id}"
}

// ai_radio_ops
resource "yandex_organizationmanager_group" "ai_radio_ops" {
  name            = "ai_radio_ops"
  description     = "ai-radio.ru operations"
  organization_id = var.organization_id
}

resource "yandex_organizationmanager_group_membership" "ai_radio_ops_membership" {
  group_id = yandex_organizationmanager_group.ai_radio_ops.id
  members  = var.operations
}

resource "yandex_organizationmanager_organization_iam_member" "ai_radio_dev_viewer" {
  organization_id = var.organization_id
  role            = "viewer"
  member          = "group:${yandex_organizationmanager_group.ai_radio_ops.id}"
}

resource "yandex_organizationmanager_organization_iam_member" "ai_radio_dev_monitoring_editor" {
  organization_id = var.organization_id
  role            = "monitoring.editor"
  member          = "group:${yandex_organizationmanager_group.ai_radio_ops.id}"
}