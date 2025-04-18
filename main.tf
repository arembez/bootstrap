resource "terraform_data" "load_environment" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "source ${path.module}/.env"
  }
}

provider "aws" {
  region = "eu-west-1"

  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check = true
  skip_region_validation = true

  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  endpoints {
    dynamodb = yandex_ydb_database_serverless.database.document_api_endpoint
  }
}

data "yandex_client_config" "client" {}

module "s3" {
  depends_on = [ yandex_kms_symmetric_key.key, yandex_iam_service_account_static_access_key.sa-static-key ]
  source = "github.com/terraform-yc-modules/terraform-yc-s3.git?ref=e4017d77de83fe105604fa7b012bc809a77c2fa2"
  bucket_name = var.project_name

  existing_service_account = {
    id = yandex_iam_service_account.sa.id
    access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
    secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }

  server_side_encryption_configuration = {
    enabled = true
    sse_algorithm = "aws:kms"
    kms_master_key_id = yandex_kms_symmetric_key.key.id
  }

  versioning = {
    enabled = true
  }

  lifecycle_rule = [{
    enabled = true
    noncurrent_version_expiration = {
      days = 29
    }
  }]
}

resource "yandex_ydb_database_serverless" "database" {
  name = "${var.project_name}-ydb"
}

resource "time_sleep" "wait_for_database" {
  create_duration = "60s"
  depends_on = [yandex_ydb_database_serverless.database]
}

resource "aws_dynamodb_table" "lock_table" {
  name = "state-lock-table"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  depends_on = [time_sleep.wait_for_database]
}