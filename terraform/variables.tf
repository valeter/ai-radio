variable "billing_account_id" {
  type = string
}

variable "service_account_id" {
  type = string
}

variable "organization_id" {
  type = string
}

variable "developers" {
  type = list(string)
}

variable "operations" {
  type = list(string)
}

variable "speech_generator_version" {
  type = string
  default = null
}
