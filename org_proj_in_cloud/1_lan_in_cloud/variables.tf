###cloud vars

variable "cloud_id" {
  type        = string
  default     = "b1g5hav5glefe06sf75l"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1gk2ihvjor87l9a6e2k"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "my_net"
  description = "VPC network name"
}


###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBQP+5HRCa7vLzAo3GYKrRFmFxeg39eAYASGLDekoC4 isup@isup-ubnt"
  description = "ssh-keygen -t ed25519"
}

variable "vm_metadata" {
  type = map(string)
  
  default = {
    "serial-port-enable" = "1"
    "ssh-keys"           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBQP+5HRCa7vLzAo3GYKrRFmFxeg39eAYASGLDekoC4 isup@isup-ubnt"
  }
}

# Приватная подсеть

variable "private_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
