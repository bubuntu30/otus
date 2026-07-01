resource "yandex_vpc_gateway" "nat_gateway" {
  name = "spark-nat"
}

resource "yandex_vpc_route_table" "nat_route_table" {
  name       = "nat-route-table"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_vpc_subnet" "subnet_nat" {
  name           = "spark-subnet-nat"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.1.0/24"]

  route_table_id = yandex_vpc_route_table.nat_route_table.id
}
