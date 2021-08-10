
resource "azurerm_public_ip" "swarm01" {
  name                = "swarm01PublicIp1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "swarm01" {
  name                = "${var.prefix}-nic-swarm01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "dynamic_ip_config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.swarm01.id
  }
}

resource "azurerm_virtual_machine" "swarm01" {
  name                  = "${var.prefix}-vm-swarm01"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.swarm01.id]
  vm_size               = var.manager_instance_type

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "swarm01disk01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "swarm01.${var.base_domain}"
    admin_username = var.swarm_admin_name
    #admin_password = "V!HWVm66QkcZk2NX" #This should be optional, but try removing it!
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.key_file)
      path = "/home/${var.swarm_admin_name}/.ssh/authorized_keys" #must be this path on Azure
    }
  }
  tags = {
    environment = "Production"
  }
}

resource "azurerm_dns_a_record" "swarm01" {
  name                = "swarm01"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_public_ip.swarm01.ip_address]
}

resource "azurerm_dns_a_record" "wc_swarm01" {
  name                = "*.swarm01"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_public_ip.swarm01.ip_address]
}

resource "azurerm_dns_cname_record" "gitlab" {
  name                = "git"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  record              = "swarm01.${var.base_domain}"
}

resource "azurerm_dns_cname_record" "gitlab_registry" {
  name                = "registry.git"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  target_resource_id  = azurerm_dns_cname_record.gitlab.id
}