terraform {
   required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~>0.130"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.44"
    }
  }
}
