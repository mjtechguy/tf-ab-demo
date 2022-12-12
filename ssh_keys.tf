resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_ssh_key" {
    filename = "./${var.deployment_name}/${var.deployment_name}_id_rsa"
    content = tls_private_key.ssh_key.private_key_pem
    file_permission = "0400"
}

resource "local_file" "public_ssh_key" {
    filename = "./${var.deployment_name}/${var.deployment_name}_public_key"
    content = tls_private_key.ssh_key.public_key_openssh
    file_permission = "0400"
}