data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

data "yandex_iam_service_account" "sa_id" {
  name      = "netology-sa"
  folder_id = var.folder_id
}