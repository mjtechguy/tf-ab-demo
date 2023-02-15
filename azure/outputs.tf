output "server_ips" {
  description = "IPs of the provisioned VMs"
  value       = azurerm_public_ip.demo_public_ip[*].ip_address
}

output "server_dns" {
  description = "DNS names of the provisioned VMs"
  value       = "${azurerm_dns_a_record.azure_demo_dns[*].name}.${var.deployment_domain}"
}

output "private_key_path" {
    description = "Private key file path for accessing servers"
    value       = local_file.ssh_key.filename
}