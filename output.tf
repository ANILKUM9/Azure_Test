#Getting PublicIP Details
data "azurerm_public_ip" "xoriet" {
  name                = azurerm_public_ip.xoriet.name
  resource_group_name = azurerm_virtual_machine.xoriet.resource_group_name
}
#Getting PublicIP Details
output "public_ip_address" {
  value = data.azurerm_public_ip.xoriet.ip_address
}
data "azurerm_network_security_group" "xoriet" {
  name                = azurerm_network_security_group.xoriet.name
  resource_group_name = azurerm_resource_group.xoriet.name
}
#Getting Location Details
output "location" {
  value = data.azurerm_network_security_group.xoriet.location
}  