output "application_public_address" {
  value = azurerm_public_ip.Team2.fqdn
}
# output "application_public_address" {
#   value = azurerm_mysql_database.Team2.server_name
# }
output "wordpress_host" {
  value = azurerm_mysql_server.Team2.fqdn
}
