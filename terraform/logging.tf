resource "yandex_logging_group" "static-gateway-log" {
  name      = "static-gateway-log"
  folder_id = local.logging_folder_id
}

resource "yandex_logging_group" "k8s-master-log" {
  name      = "k8s-master-log"
  folder_id = local.logging_folder_id
}

resource "yandex_logging_group" "k8s-alb-log" {
  name      = "k8s-alb-log"
  folder_id = local.logging_folder_id
}

resource "yandex_logging_group" "speech-generator-log" {
  name      = "speech-generator-log"
  folder_id = local.logging_folder_id
}
