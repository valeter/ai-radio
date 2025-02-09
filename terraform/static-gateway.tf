resource "yandex_api_gateway" "ai-radio-static-gateway" {
  folder_id = var.folder_id
  name      = "ai-radio-static-gateway"
  spec      = file("../openapi/static.yaml")
}
