# Общая сеть

resource "yandex_vpc_network" "my_net" {
  name = var.vpc_name
}

# Публичная подсеть

resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = var.default_cidr
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_net.id
}

# NAT инстанс с публичным ip

resource "yandex_compute_instance" "nat_instance" {
  name        = "nat-instance"
  hostname    = "nat"
  zone        = var.default_zone
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat = true
  }

  metadata = var.vm_metadata

 }

# Виртуальная машина в публичной сети с публичным ip

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

 resource "yandex_compute_instance" "vm_public" {
  name        = "vm-public"
  hostname    = "vm-public"
  zone        = var.default_zone
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.10"
    nat = true
  }

  metadata = var.vm_metadata

 }

 # Приватная подсеть

resource "yandex_vpc_subnet" "private" {
  v4_cidr_blocks = var.private_cidr
  zone           = var.default_zone
  network_id     = yandex_vpc_network.my_net.id
}

# таблица маршрутизации

resource "yandex_vpc_route_table" "lab-rt-a" {
  network_id = yandex_vpc_network.my_net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }

}

# Виртуальная машина в приватной сети

 resource "yandex_compute_instance" "vm_private" {
  name        = "vm-private"
  hostname    = "vm-private"
  zone        = var.default_zone
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    ip_address = "192.168.20.10"
  }

  metadata = var.vm_metadata

 }