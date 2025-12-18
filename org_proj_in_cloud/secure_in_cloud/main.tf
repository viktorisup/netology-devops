
// Создание семетричного ключа
resource "yandex_kms_symmetric_key" "key-a" {
  name                = "my-first-key"
  description         = "key for encrypted bucket"
  default_algorithm   = "AES_128"
  deletion_protection = true
  lifecycle {
    prevent_destroy = true
  }
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = data.yandex_iam_service_account.sa_id.id
  description        = "static access key for object storage"
}

// Шифрование бакета
resource "yandex_storage_bucket" "bucket" {
  bucket     = "isupov-vn-2025-12-18"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

// Загрузка картинки
resource "yandex_storage_object" "picture" {
  bucket = yandex_storage_bucket.bucket.bucket
  key    = "picture.jpg"
  source = "screenshots/picture.jpg"
  acl    = "public-read"
}