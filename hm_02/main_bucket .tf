terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.79.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "yandex" {
  cloud_id                 = "b1gk4mel6toc76mu6nkt"
  folder_id                = "b1gbn46dh3brmc00uia5"
  zone                     = "ru-central1-a"
  service_account_key_file = "terraform-sa-key.json"
}

resource "yandex_iam_service_account" "new_sa" {
  name = "otus-hm3-new-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "new_sa_editor" {
  folder_id = "b1gbn46dh3brmc00uia5"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.new_sa.id}"
}

resource "yandex_storage_bucket" "bucket_hm2" {
  bucket = "otus-hm2-bucket"

  anonymous_access_flags {
    read = true
    list = true
  }
}

resource "yandex_storage_bucket" "bucket" {
  bucket = "otus-hm3-bucket"

  anonymous_access_flags {
    read = true
    list = true
  }
}

output "bucket_public_url" {
  value = "https://${yandex_storage_bucket.bucket.bucket}.storage.yandexcloud.net"
}
