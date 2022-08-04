resource "azurerm_lb" "Team2" {
  name                = "Team2-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.Team2.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.Team2.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.Team2.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "Team2" {
  resource_group_name = azurerm_resource_group.Team2.name
  loadbalancer_id     = azurerm_lb.Team2.id
  name                = "ssh-running-probe"
  port                = var.application_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = azurerm_resource_group.Team2.name
  loadbalancer_id                = azurerm_lb.Team2.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.Team2.id
}

resource "azurerm_linux_virtual_machine_scale_set" "Team2" {
  name                            = "vmscaleset"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.Team2.name
  sku                             = "Standard_D2S_v3"
  instances                       = 1
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  custom_data                     = filebase64("customdata.tpl")
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "NetworkInterface"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.Team2.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary                                = true
    }
  }

  tags = var.tags
}

# data "template_file" "script" {
#   # template = filebase64("/home/ec2-user/wordpress-azure-terraform-T3/wordpress.sh")
#   template = file("wordpress.conf")
# }

# data "template_cloudinit_config" "config" {
#   gzip          = true
#   base64_encode = true

#   part {
#     # filename     = "wordpress.sh"
#     filename     = "wordpress.conf"
#     content_type = "text/cloud-config"
#     content      = data.template_file.script.rendered
#   }

#   depends_on = [azurerm_mysql_server.wordpress]
# }
