resource "yandex_kubernetes_cluster" "k8s-cluster" {
  folder_id                = local.network_folder_id
  name                     = "k8s-cluster"
  cluster_ipv4_range       = "10.112.0.0/16"
  service_ipv4_range       = "10.96.0.0/16"
  node_ipv4_cidr_mask_size = 28
  network_id               = yandex_vpc_network.default-network.id
  service_account_id       = yandex_iam_service_account.k8s-sa.id
  node_service_account_id  = yandex_iam_service_account.ai-radio-container-registry-sa.id

  master {
    public_ip         = true
    version           = "1.30"
    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        start_time = "01:00"
        duration   = "5h"
      }
    }
    master_logging {
      log_group_id               = yandex_logging_group.k8s-master-log.id
      enabled                    = true
      audit_enabled              = true
      cluster_autoscaler_enabled = true
      events_enabled             = true
      kube_apiserver_enabled     = true
    }
    security_group_ids = [yandex_vpc_security_group.k8s-sg.id]
    zonal {
      subnet_id = yandex_vpc_subnet.private-subnet-d.id
      zone      = "ru-central1-d"
    }
  }
}

resource "yandex_kubernetes_node_group" "worker-nodes-d" {
  name       = "worker-nodes-d"
  cluster_id = yandex_kubernetes_cluster.k8s-cluster.id
  depends_on = [yandex_organizationmanager_os_login_settings.os_login_settings]

  version = "1.30"
  deploy_policy {
    max_expansion   = 3
    max_unavailable = 0
  }
  scale_policy {
    fixed_scale {
      size = 1
    }
  }
  allocation_policy {
    location {
      zone = "ru-central1-d"
    }
  }
  instance_template {
    platform_id = "standard-v3"
    resources {
      core_fraction = 100
      cores         = 2
      memory        = 2
    }
    network_interface {
      nat                = true
      ipv4 = true
      ipv6 = false
      security_group_ids = [yandex_vpc_security_group.k8s-sg.id]
      subnet_ids         = [yandex_vpc_subnet.private-subnet-d.id]
    }
    boot_disk {
      size = 64
      type = "network-ssd"
    }
    container_network {
      pod_mtu = 0
    }
    container_runtime {
      type = "containerd"
    }
    scheduling_policy {
      preemptible = false
    }
    metadata = {
      "enable-oslogin" = "true"
    }
  }
  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
    maintenance_window {
      start_time = "01:00"
      duration   = "5h"
    }
  }
}
