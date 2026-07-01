resource "yandex_dataproc_cluster" "spark_cluster" {
  name               = "spark-cluster"
  description        = "Spark cluster for fraud analysis"
  service_account_id = yandex_iam_service_account.spark_sa.id
  bucket             = yandex_storage_bucket.fraud_bucket.bucket
  zone_id            = var.zone

  security_group_ids = []

  depends_on = [
    yandex_iam_service_account.spark_sa,
    yandex_storage_bucket.fraud_bucket
  ]

  cluster_config {
    version_id = "2.1"

  hadoop {
  services = ["SPARK", "YARN", "HDFS"]

  ssh_public_keys = [
    trimspace(file("/home/suv/.ssh/yandex_dp.pub"))
  ]
}

    subcluster_spec {
      name = "master"
      role = "MASTERNODE"

      resources {
        resource_preset_id = "s3-c2-m8"
        disk_type_id       = "network-hdd"
        disk_size          = 40
      }

      subnet_id   = yandex_vpc_subnet.subnet_nat.id
      hosts_count = 1
    }

    subcluster_spec {
      name = "data"
      role = "DATANODE"

      resources {
        resource_preset_id = "s3-c4-m16"
        disk_type_id       = "network-hdd"
        disk_size          = 128
      }

      subnet_id   = yandex_vpc_subnet.subnet.id
      hosts_count = 3
    }
  }
}
