resource "yandex_api_gateway" "ai-radio-static-gateway" {
  name = "ai-radio-static-gateway"
  spec = file("../openapi/static.yaml")
}
