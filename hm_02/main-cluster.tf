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


variable "bucket_name" {
  default = "otus-hm2-bucket"
}

variable "service_account_id" {
  default = "ajejcf5uclopl8be0vmt"
}


variable "route_table_id" {
  default = "enpdl1gsh7ccdf1743vt"  
}

data "yandex_vpc_route_table" "ydp_route" {
  route_table_id = var.route_table_id
}


data "yandex_vpc_network" "ydp_network" {
  network_id = data.yandex_vpc_route_table.ydp_route.network_id
}


resource "yandex_vpc_subnet" "dataproc_subnet" {
  name           = "dataproc-subnet"
  zone           = "ru-central1-a"
  network_id     = data.yandex_vpc_network.ydp_network.id
  v4_cidr_blocks = ["10.0.3.0/24"]  
  route_table_id = var.route_table_id  
}


resource "yandex_dataproc_cluster" "spark_cluster" {
  name               = "otus-spark-cluster"
  folder_id          = "b1gbn46dh3brmc00uia5"
  service_account_id = var.service_account_id
  bucket             = var.bucket_name

  cluster_config {
    version_id = "2.0"

    hadoop {
      ssh_public_keys = [
        file("${path.module}/otus_dataproc_key.pub")
      ]
    }

    subcluster_spec {
      name        = "master"
      role        = "MASTERNODE"
      hosts_count = 1
      subnet_id   = yandex_vpc_subnet.dataproc_subnet.id

      resources {
        resource_preset_id = "s3-c2-m8"
        disk_size          = 40
      }
    }

    subcluster_spec {
      name        = "datanode"
      role        = "DATANODE"
      hosts_count = 2
      subnet_id   = yandex_vpc_subnet.dataproc_subnet.id

      resources {
        resource_preset_id = "s3-c4-m16"
        disk_size          = 128
      }
    }

    subcluster_spec {
      name        = "worker"
      role        = "COMPUTENODE"
      hosts_count = 2
      subnet_id   = yandex_vpc_subnet.dataproc_subnet.id

      resources {
        resource_preset_id = "s3-c4-m16"
        disk_size          = 128
      }
    }
  }

  deletion_protection = true
}

output "spark_cluster_name" {
  value = yandex_dataproc_cluster.spark_cluster.name
}

output "dataproc_subnet_id" {
  value = yandex_vpc_subnet.dataproc_subnet.id
  description = "ID подсети, используемой для Dataproc кластера"
}

output "network_id" {
  value = data.yandex_vpc_network.ydp_network.id
  description = "ID сети, в которой создан кластер"
}

output "route_table_id_used" {
  value = var.route_table_id
  description = "ID используемой таблицы маршрутизации с NAT"
}
