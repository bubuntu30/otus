resource "yandex_storage_bucket" "fraud_bucket" {
  bucket    = var.bucket_name
  folder_id = var.folder_id

  acl = "public-read"
}
