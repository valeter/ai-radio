# Provider configuration
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = null
}

# General configuration
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "ai-radio-caster"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "ai-radio"
}

variable "create_namespace" {
  description = "Create namespace if it doesn't exist"
  type        = bool
  default     = true
}

# Deployment configuration
variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "image_repository" {
  description = "Container image repository"
  type        = string
  default     = "cr.yandex/crpql2lunj3qmje5rnos/ai-radio-caster"
}

variable "image_tag" {
  description = "Container image tag"
  type        = string
  default     = "latest"
}

variable "image_pull_policy" {
  description = "Image pull policy"
  type        = string
  default     = "Always"
}

variable "image_pull_secrets" {
  description = "Image pull secrets"
  type        = list(string)
  default     = []
}

variable "container_port" {
  description = "Container port (nginx)"
  type        = number
  default     = 32745
}

variable "privileged" {
  description = "Run container in privileged mode (required for s3fs)"
  type        = bool
  default     = true
}

# Resources
variable "resources_requests_cpu" {
  description = "CPU request"
  type        = string
  default     = "100m"
}

variable "resources_requests_memory" {
  description = "Memory request"
  type        = string
  default     = "128M"
}

variable "resources_limits_cpu" {
  description = "CPU limit"
  type        = string
  default     = null
}

variable "resources_limits_memory" {
  description = "Memory limit"
  type        = string
  default     = null
}

# Health probes
variable "health_probe_path" {
  description = "Health probe path"
  type        = string
  default     = "/ping"
}

# Service configuration
variable "service_type" {
  description = "Kubernetes service type"
  type        = string
  default     = "NodePort"
}

# Service Account
variable "create_service_account" {
  description = "Create service account"
  type        = bool
  default     = true
}

variable "service_account_cluster_admin" {
  description = "Grant cluster-admin role to service account"
  type        = bool
  default     = true
}

# Ingress configuration
variable "ingress_enabled" {
  description = "Enable ingress"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
  default     = "stream.ai-radio.ru"
}

variable "ingress_path" {
  description = "Ingress path"
  type        = string
  default     = "/"
}

variable "ingress_path_type" {
  description = "Ingress path type"
  type        = string
  default     = "Exact"
}

variable "ingress_class_name" {
  description = "Ingress class name (leave empty for default or Yandex Cloud ALB)"
  type        = string
  default     = ""
}

# Yandex Cloud ALB configuration
variable "yc_alb_subnets" {
  description = "Yandex Cloud ALB subnets"
  type        = string
  default     = "fl8d2jr8im4t5coavo64"
}

variable "yc_alb_security_groups" {
  description = "Yandex Cloud ALB security groups"
  type        = string
  default     = "enpfr1ed7imm6nej45ht"
}

variable "yc_alb_external_ipv4" {
  description = "Yandex Cloud ALB external IPv4 address"
  type        = string
  default     = "51.250.115.74"
}

variable "yc_alb_group_name" {
  description = "Yandex Cloud ALB group name"
  type        = string
  default     = "ai-radio"
}

variable "yc_alb_log_group_id" {
  description = "Yandex Cloud ALB log group ID"
  type        = string
  default     = "e239var1beii4fu9ecpa"
}

variable "yc_tls_secret_name" {
  description = "Yandex Cloud TLS certificate secret name"
  type        = string
  default     = "yc-certmgr-cert-id-fpqlooi4u8gmukddm0pm"
}

# HPA configuration
variable "hpa_enabled" {
  description = "Enable Horizontal Pod Autoscaler"
  type        = bool
  default     = false
}

variable "hpa_min_replicas" {
  description = "HPA minimum replicas"
  type        = number
  default     = 1
}

variable "hpa_max_replicas" {
  description = "HPA maximum replicas"
  type        = number
  default     = 100
}

variable "hpa_target_cpu_utilization" {
  description = "HPA target CPU utilization percentage"
  type        = number
  default     = 80
}

# Labels
variable "labels" {
  description = "Additional labels to apply to all resources"
  type        = map(string)
  default     = {}
}
