resource "yandex_iam_service_account" "spark_sa" {
  name        = "spark-sa"
  description = "Service account for Spark Data Proc cluster"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.spark_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "dataproc_agent" {
  folder_id = var.folder_id
  role      = "dataproc.agent"
  member    = "serviceAccount:${yandex_iam_service_account.spark_sa.id}"
}

