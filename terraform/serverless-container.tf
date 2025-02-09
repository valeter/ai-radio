
resource "yandex_serverless_container" "ai-radio-caster-container" {
  name               = "ai-radio-caster-container"
  memory             = 512
  service_account_id = var.service_account_id
  execution_timeout  = "15s"
  cores              = 2
  core_fraction      = 100
  concurrency        = 16
  runtime {
    type = "http"
  }
  image {
    url = "cr.yandex/${yandex_container_registry.ai-radio-registry.id}/ai-radio-caster:v1.21"
  }
  mounts {
    mount_point_path = "/music"
    mode             = "ro"
    object_storage {
      bucket = yandex_storage_bucket.ai-radio-music-bucket.bucket
      prefix = "static"
    }
  }
  provision_policy {
    min_instances = 1
  }
  connectivity {
    network_id = module.yc-vpc.vpc_id
  }
}
