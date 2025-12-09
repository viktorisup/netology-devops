# Создание бакета

resource "yandex_storage_bucket" "bucket" {
  bucket    = "isupov-vn-2025-12-08"
  folder_id = var.folder_id
}

# Загрузка картинки

resource "yandex_storage_object" "picture" {
  bucket = yandex_storage_bucket.bucket.bucket
  key    = "picture.jpg"
  source = "screenshots/picture.jpg"
  acl    = "public-read"
}

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

# Создание Instance Group

resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-ig"
  folder_id          = var.folder_id
  service_account_id = data.yandex_iam_service_account.sa_id.id

  instance_template {
    platform_id = "standard-v1"
    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 10
        type     = "network-hdd"
      }
    }

    network_interface {
      subnet_ids      = [yandex_vpc_subnet.public.id]
      nat            = true
    }

    scheduling_policy {
      preemptible = false
    }

    metadata = {
      ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = <<-EOF
        #!/bin/bash
        cat > /var/www/html/index.html <<PAGE
        <!DOCTYPE html> <html> <head>
          <meta charset="UTF-8">
          <title>LAMP + Object Storage</title>
          <style>
            body, html {
              margin: 0;
              padding: 0;
              width: 100%;
              height: 100%;
              position: relative;
            }
            img {
              width: 100%;
              height: 100%;
              object-fit: cover;
            }
            .overlay-text {
              position: absolute;
              z-index: 1;
              color: white;
            }
            .greeting {
              top: 5%;
              left: 5%;
              font-size: 36px;
            }
            .subtext {
              top: 10%;
              left: 10%;
              font-size: 24px;
            }
          </style> </head> <body>
          <h1 class="overlay-text greeting">Привет из Instance Group!</h1>
          <p class="overlay-text subtext">Картинка из Object Storage</p>
          <img src="https://storage.yandexcloud.net/isupov-vn-2025-12-08/picture.jpg" alt="Картинка из облака" /> </body>
        </html>
        PAGE
        chown www-data:www-data /var/www/html/index.html || true
      EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.default_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 2
    max_expansion   = 1
    max_deleting    = 1
  }

  health_check {
    interval            = 10
    timeout             = 5
    unhealthy_threshold = 3
    healthy_threshold   = 2

    http_options {
      port = 80
      path = "/"
    }
  }
}

# Динамический таргет на группу ВМ

resource "yandex_lb_target_group" "tg" {
  name      = "lamp-tg"
  folder_id = var.folder_id

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp_group.instances
    content {
      subnet_id = yandex_vpc_subnet.public.id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

# Создание балансировщика

resource "yandex_lb_network_load_balancer" "nlb" {
  name      = "lamp-nlb"
  folder_id = var.folder_id
  type      = "external"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
      interval            = 10
      timeout             = 5
      unhealthy_threshold = 3
      healthy_threshold   = 2
    }
  }
}
