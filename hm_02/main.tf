terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.193"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone                     = var.zone
  service_account_key_file = "/home/suv/key.json"
}

resource "yandex_storage_bucket" "otus_bucket" {
  bucket = var.bucket_name
}
