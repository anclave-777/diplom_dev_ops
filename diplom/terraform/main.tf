terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  
}

provider "yandex" {
  token     = "AQAAAAABKxJEAATuwYzoB2zkCU3ctz_ET7MEUzQ"
  cloud_id  = "b1g3m87vmpkc5pf4uk8k"
  folder_id = "b1ga6pbom71ac8qn3331"
  zone      = "ru-central1-a"
}


resource yandex_compute_image ubu-img {
  name          = "ubuntu-20-04-lts-v202109082"
  source_image  = "fd81hgrcv6lsnkremf32"
}

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_network" "lab-net" {
  name = "lab-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "lab-subnet-a" {
  name           = "lab-subnet-a"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.lab-net.id
}



###
#Nginx
###

resource "yandex_compute_instance" "anclave777" {
  name = "anclave777"
  hostname = "anclave-777.ru"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    initialize_params {
      image_id = "${yandex_compute_image.ubu-img.id}"
    size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
    nat_ip_address = var.yc_reserved_ip
  }

  metadata = {
    user-data = "${file("meta.txt")}"
    ssh-keys  = "ubuntu:${file("id_rsa.pub")}"
  }
}

####
#Mysql
####


resource "yandex_compute_instance" "db01" {
  name     = "db01"
  hostname = "db01.anclave-777.ru"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

resource "yandex_compute_instance" "db02" {
  name     = "db02"
  hostname = "db02.anclave-777.ru"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
      size = 10
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

###
#Wordpress
###

resource "yandex_compute_instance" "app" {
  name     = "app"
  hostname = "app.anclave-777.ru"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
      size     = 6
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
#    ssh-keys  = "sovar:${file("pub")}"
  }
}

###
#Gitlab
###


resource "yandex_compute_instance" "gitlab" {
  name     = "gitlab"
  hostname = "gitlab.anclave-777.ru"
#  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = "fd8cb3pa2c61fluu8v3v"
#      image_id    = "fd833bu60pmtkrrrp6gd"
#      image_id = "fd8fte6bebi857ortlja"
#      image_id = "fd81hgrcv6lsnkremf32"
      size        = "12"
    }
  }

#  scheduling_policy {
#    preemptible = true
#  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

###
#Gitlab_runner
###

resource "yandex_compute_instance" "runner" {
  name     = "runner"
  hostname = "runner.anclave-777.ru"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

resource "yandex_compute_instance" "monitoring" {
  name     = "monitoring"
  hostname = "monitoring.anclave-777.ru"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fte6bebi857ortlja"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}
