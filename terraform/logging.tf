resource "yandex_logging_group" "static-gateway-log" {
  name      = "static-gateway-log"
  folder_id = local.logging_folder_id
}
