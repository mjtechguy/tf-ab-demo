data "template_file" "azure_init" {
  count    = var.azure_enabled ? 1 : 0
  template = "${file("./assets/templates/user_data.tmpl")}"
  vars     = {
      user = var.user
      ssh-pub = tls_private_key.gen_ssh_key.public_key_openssh
  }
}

resource "azurerm_resource_group" "demo_rg" {
  count    = var.azure_enabled ? 1 : 0
  location = var.azure_region
  name     = "${var.deployment_name}-rg"
}

# Create virtual network
resource "azurerm_virtual_network" "demo_network" {
  count               = var.azure_enabled ? 1 : 0
  name                = "${var.deployment_name}-net"
  address_space       = ["${var.azure_address_space}"]
  location            = azurerm_resource_group.demo_rg[0].location
  resource_group_name = azurerm_resource_group.demo_rg[0].name
}

# Create subnet
resource "azurerm_subnet" "demo_subnet" {
  count                = var.azure_enabled ? 1 : 0
  name                 = "${var.deployment_name}-subnet"
  resource_group_name  = azurerm_resource_group.demo_rg[0].name
  virtual_network_name = azurerm_virtual_network.demo_network[0].name
  address_prefixes     = ["${var.azure_address_prefix}"]
}

# Create public IPs
resource "azurerm_public_ip" "demo_public_ip" {
  count               = var.azure_enabled ? var.azure_vm_count : 0
  name                = "${var.deployment_name}-public-ip-${count.index}"
  location            = azurerm_resource_group.demo_rg[0].location
  resource_group_name = azurerm_resource_group.demo_rg[0].name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "demo_nsg" {
  count               = var.azure_enabled ? 1 : 0
  name                = "${var.deployment_name}-NetworkSecurityGroup"
  location            = azurerm_resource_group.demo_rg[0].location
  resource_group_name = azurerm_resource_group.demo_rg[0].name

  security_rule {
    name                       = "all"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "demo_nic" {
  count               = var.azure_enabled ? var.azure_vm_count : 0
  name                = "${var.deployment_name}-nic-${count.index}"
  location            = azurerm_resource_group.demo_rg[0].location
  resource_group_name = azurerm_resource_group.demo_rg[0].name
  depends_on = [
    azurerm_public_ip.demo_public_ip
  ]

  ip_configuration {
    name                          = "${var.deployment_name}-nic_configuration"
    subnet_id                     = azurerm_subnet.demo_subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.demo_public_ip.*.id, count.index)}"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "demo_sg_assoc" {
  count    = var.azure_enabled ? 1 : 0
  network_interface_id      = "${element(azurerm_network_interface.demo_nic.*.id, count.index)}"
  network_security_group_id = azurerm_network_security_group.demo_nsg[0].id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "ab_demo_server" {
  count                 = var.azure_enabled ? var.azure_vm_count : 0
  name                  = "${var.deployment_name}-caz-${count.index}"
  location              = azurerm_resource_group.demo_rg[0].location
  resource_group_name   = azurerm_resource_group.demo_rg[0].name
  network_interface_ids = ["${element(azurerm_network_interface.demo_nic.*.id, count.index)}"]
  user_data             = "${base64encode(data.template_file.azure_init[0].rendered)}"
  size                  = var.azure_compute_size

  os_disk {
    name                 = "${var.deployment_name}-osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.azure_root_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202211151"
  }

  computer_name                   = "${var.deployment_name}-caz-${count.index}"
  admin_username                  = var.user
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.user
    public_key = tls_private_key.gen_ssh_key.public_key_openssh
  }
}