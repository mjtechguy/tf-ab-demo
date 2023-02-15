# Cleans up folders on destroy

resource "null_resource" "deployment_folder" {
  triggers = {
    deployment_folder = var.deployment_name
  }

  provisioner "local-exec" {
    command = "rm -rf ./generated_files/${self.triggers.deployment_folder}"
    when = destroy
  }
}