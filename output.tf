resource "local_file" "key" {
  filename = "${path.root}/.key.json"
  file_permission = "0600"
  content = <<EOH
  {
    "id": "${yandex_iam_service_account_key.sa-auth-key.id}",
    "created_at": "${yandex_iam_service_account_key.sa-auth-key.created_at}",
    "key_algorithm": "${yandex_iam_service_account_key.sa-auth-key.key_algorithm}",
    "public_key": ${jsonencode(yandex_iam_service_account_key.sa-auth-key.public_key)},
    "private_key": ${jsonencode(yandex_iam_service_account_key.sa-auth-key.private_key)}
  }
  EOH

}

resource "local_file" "env" {
  filename = "${path.root}/.env"
  file_permission = "0600"
  content = <<EOH
    export AWS_ACCESS_KEY_ID="${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
    export AWS_SECRET_ACCESS_KEY="${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  EOH
}

resource "local_file" "backend_tf" {
  filename = "${path.root}/backend.tf"
  file_permission = "0644"
  content = templatefile("${path.module}/backend.tftpl", {
     bucket_id = module.s3.bucket_name
     key = "terraform.tfstate",
     dynamodb_endpoint = yandex_ydb_database_serverless.database.document_api_endpoint,
     dynamodb_table = aws_dynamodb_table.lock_table.id
  })
}