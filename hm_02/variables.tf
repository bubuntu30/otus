variable "service_account_key_file" {
  description = "~/key.json"
  type        = string
}

variable "bucket_name" {
  description = "outus2-bucket-savina"
  type        = string
}

variable "zone" {
  description = "Зона создания ресурсов"
  type        = string
  default     = "ru-central1-a"
}
