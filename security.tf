resource "yandex_iam_service_account" "sa" {
  name = "${var.project_name}-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-admin-s3" {
  folder_id = data.yandex_client_config.client.folder_id
  role = "storage.admin"
  member = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor-kms" {
  folder_id = data.yandex_client_config.client.folder_id
  role = "kms.editor"
  member = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor-ydb" {
  folder_id = data.yandex_client_config.client.folder_id
  role = "ydb.editor"
  member = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
}

resource "yandex_kms_symmetric_key" "key" {
  name = "${var.project_name}-kms"
  rotation_period = "8760h"
}

# Создание сервисного акканута для Terraform
#resource "yandex_iam_service_account" "sa-gitlab-tf" {
#  name        = "gitlab-terraform-sa"
#  description = "Service account for Terraform in Gitlab"
#}

# Назначение роли сервисному аккаунту - admin
#resource "yandex_resourcemanager_folder_iam_member" "sa_terraform_admin" {
#  folder_id = data.yandex_client_config.client.folder_id
#  role      = "admin"
#  member    = "serviceAccount:${yandex_iam_service_account.sa-gitlab-tf.id}"
#}

# Создание авторизованного ключа доступа
#resource "yandex_iam_service_account_key" "sa-auth-key" {
#  service_account_id = "${yandex_iam_service_account.sa-gitlab-tf.id}"
#  description        = "Key for service account"
#  key_algorithm      = "RSA_2048"
#}

# Создание файла .key.json с ключом доступа для Terraform
# "service_account_id": "${yandex_iam_service_account.sa-gitlab-tf.id}",