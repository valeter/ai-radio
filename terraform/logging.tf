resource "yandex_logging_group" "static_gateway_log" {
  name      = "static_gateway_log"
  folder_id = local.logging_folder_id
}
