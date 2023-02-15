# Azure Cloud
resource "azurerm_dns_a_record" "azure_demo_dns" {
  count               = "${var.azure_enabled == "true" && var.dns_service == "azure" && var.azure_vm_count > 0 ? var.azure_vm_count:0}"
  name                = "${element(azurerm_linux_virtual_machine.ab_demo_server.*.name, count.index)}"
  zone_name           = var.deployment_domain
  resource_group_name = "mjtechguy"
  ttl                 = 300
  records             = ["${element(azurerm_public_ip.demo_public_ip.*.ip_address, count.index)}"]
  depends_on          = [azurerm_linux_virtual_machine.ab_demo_server]
}