########################################
### Azure_Appliance2.tf
########################################
### Interop Tokyo 2021
### ShowNet Cloud NOC
###  Ryosuke Kato
###  Mami Nakamura
###  Shuhei Uda
########################################

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  alias           = "appliance2"
  subscription_id = "b9922ef0-91eb-4f0c-aec7-f41593ace4d6"
  features {}
}

variable "azure_appliance2_common_parameter" {
  type = map(any)
  default = {
    "location"            = "japaneast"
    "resource_group_name" = "cloud-noc-managed-appliance2"
  }
}

variable "vnet_appliance2_parameter" {
  type = map(any)
  default = {
    "azure_management2_subnet_address_prefixes"          = "172.16.19.224/27"
    "azure_outbound_management2_subnet_address_prefixes" = "172.20.19.224/27"
    "azure_private3_subnet_address_prefixes"             = "10.0.218.128/26"
    "azure_global2_subnet_address_prefixes"              = "10.0.218.224/27"
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "resource_group_appliance2" {
  provider = azurerm.appliance2
  name     = lookup(var.azure_appliance2_common_parameter, "resource_group_name")
  location = lookup(var.azure_appliance2_common_parameter, "location")
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "azure_management2_subnet_network_security_group_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-mgmt-2-nsg"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name
  security_rule {
    name                       = "allow_management_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.0.0/16"
    destination_address_prefix = "172.16.0.0/16"
  }
  security_rule {
    name                       = "allow_loadbalancer_inbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_management_outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.16.0.0/16"
    destination_address_prefix = "172.16.0.0/16"
  }
  security_rule {
    name                       = "allow_kms_outbound"
    priority                   = 4093
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "23.102.135.246"
  }
  security_rule {
    name                       = "allow_loadbalancer_outbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureLoadBalancer"
  }
  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "azure_outbound_management2_subnet_network_security_group_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-ob-mgmt-2-nsg"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name
  security_rule {
    name                       = "allow_outbound_management_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.20.0.0/16"
    destination_address_prefix = "172.20.0.0/16"
  }
  security_rule {
    name                       = "allow_loadbalancer_inbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_outbound_management_outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "172.20.0.0/16"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_kms_outbound"
    priority                   = 4093
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "23.102.135.246"
  }
  security_rule {
    name                       = "allow_loadbalancer_outbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureLoadBalancer"
  }
  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "azure_private3_subnet_network_security_group_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-private-3-nsg"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name
  security_rule {
    name                       = "allow_private_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "10.0.0.0/8"
  }
  security_rule {
    name                       = "allow_loadbalancer_inbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_private_outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "10.0.0.0/8"
  }
  security_rule {
    name                       = "allow_kms_outbound"
    priority                   = 4093
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "23.102.135.246"
  }
  security_rule {
    name                       = "allow_loadbalancer_outbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureLoadBalancer"
  }
  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "azure_global2_subnet_network_security_group_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-global-2-nsg"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name
  security_rule {
    name                       = "allow_global_inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "10.0.0.4/32"
  }
  security_rule {
    name                       = "allow_loadbalancer_inbound"
    priority                   = 4095
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_kms_outbound"
    priority                   = 4093
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "23.102.135.246"
  }
  security_rule {
    name                       = "allow_loadbalancer_outbound"
    priority                   = 4095
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureLoadBalancer"
  }
  security_rule {
    name                       = "deny_all_outbound"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table
resource "azurerm_route_table" "azure_management2_subnet_route_table_appliance2" {
  provider                      = azurerm.appliance2
  name                          = "azure-mgmt-2-route-table"
  location                      = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name           = azurerm_resource_group.resource_group_appliance2.name
  disable_bgp_route_propagation = false
  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None"
  }
}

resource "azurerm_route_table" "azure_outbound_management2_subnet_route_table_appliance2" {
  provider                      = azurerm.appliance2
  name                          = "azure-ob-mgmt-2-route-table"
  location                      = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name           = azurerm_resource_group.resource_group_appliance2.name
  disable_bgp_route_propagation = false
  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None" #Outbound は全て VWAN に向ける
  }
}

resource "azurerm_route_table" "azure_private3_subnet_route_table_appliance2" {
  provider                      = azurerm.appliance2
  name                          = "azure-private-3-route-table"
  location                      = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name           = azurerm_resource_group.resource_group_appliance2.name
  disable_bgp_route_propagation = false
  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "None"
  }
}

resource "azurerm_route_table" "azure_global2_subnet_route_table_appliance2" {
  provider                      = azurerm.appliance2
  name                          = "azure-global-2-route-table"
  location                      = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name           = azurerm_resource_group.resource_group_appliance2.name
  disable_bgp_route_propagation = true #VWAN, ShowNet と分離するために BGP での経路伝達を無効化
  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet_appliance2" {
  provider = azurerm.appliance2
  name     = "azure-vnet-2"
  address_space = [
    lookup(var.vnet_appliance2_parameter, "azure_management2_subnet_address_prefixes"),
    lookup(var.vnet_appliance2_parameter, "azure_outbound_management2_subnet_address_prefixes"),
    lookup(var.vnet_appliance2_parameter, "azure_private3_subnet_address_prefixes"),
    lookup(var.vnet_appliance2_parameter, "azure_global2_subnet_address_prefixes")
  ]
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "azure_management2_subnet_appliance2" {
  provider             = azurerm.appliance2
  name                 = "azure-mgmt-2"
  resource_group_name  = azurerm_resource_group.resource_group_appliance2.name
  virtual_network_name = azurerm_virtual_network.vnet_appliance2.name
  address_prefixes     = [lookup(var.vnet_appliance2_parameter, "azure_management2_subnet_address_prefixes")]
}

resource "azurerm_subnet" "azure_outbound_management2_subnet_appliance2" {
  provider             = azurerm.appliance2
  name                 = "azure-ob-mgmt-2"
  resource_group_name  = azurerm_resource_group.resource_group_appliance2.name
  virtual_network_name = azurerm_virtual_network.vnet_appliance2.name
  address_prefixes     = [lookup(var.vnet_appliance2_parameter, "azure_outbound_management2_subnet_address_prefixes")]
}

resource "azurerm_subnet" "azure_private3_subnet_appliance2" {
  provider             = azurerm.appliance2
  name                 = "azure-private-3"
  resource_group_name  = azurerm_resource_group.resource_group_appliance2.name
  virtual_network_name = azurerm_virtual_network.vnet_appliance2.name
  address_prefixes     = [lookup(var.vnet_appliance2_parameter, "azure_private3_subnet_address_prefixes")]
}

resource "azurerm_subnet" "azure_global2_subnet_appliance2" {
  provider             = azurerm.appliance2
  name                 = "azure-global-2"
  resource_group_name  = azurerm_resource_group.resource_group_appliance2.name
  virtual_network_name = azurerm_virtual_network.vnet_appliance2.name
  address_prefixes     = [lookup(var.vnet_appliance2_parameter, "azure_global2_subnet_address_prefixes")]
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "azure_management2_subnet_network_security_group_association_appliance2" {
  provider                  = azurerm.appliance2
  subnet_id                 = azurerm_subnet.azure_management2_subnet_appliance2.id
  network_security_group_id = azurerm_network_security_group.azure_management2_subnet_network_security_group_appliance2.id
}

resource "azurerm_subnet_network_security_group_association" "azure_outbound_management2_subnet_network_security_group_association_appliance2" {
  provider                  = azurerm.appliance2
  subnet_id                 = azurerm_subnet.azure_outbound_management2_subnet_appliance2.id
  network_security_group_id = azurerm_network_security_group.azure_outbound_management2_subnet_network_security_group_appliance2.id
}

resource "azurerm_subnet_network_security_group_association" "azure_private3_subnet_network_security_group_association_appliance2" {
  provider                  = azurerm.appliance2
  subnet_id                 = azurerm_subnet.azure_private3_subnet_appliance2.id
  network_security_group_id = azurerm_network_security_group.azure_private3_subnet_network_security_group_appliance2.id
}

resource "azurerm_subnet_network_security_group_association" "azure_global2_subnet_network_security_group_association_appliance2" {
  provider                  = azurerm.appliance2
  subnet_id                 = azurerm_subnet.azure_global2_subnet_appliance2.id
  network_security_group_id = azurerm_network_security_group.azure_global2_subnet_network_security_group_appliance2.id
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association
resource "azurerm_subnet_route_table_association" "azure_management2_subnet_route_table_association_appliance2" {
  provider       = azurerm.appliance2
  subnet_id      = azurerm_subnet.azure_management2_subnet_appliance2.id
  route_table_id = azurerm_route_table.azure_management2_subnet_route_table_appliance2.id
}

resource "azurerm_subnet_route_table_association" "azure_outbound_management2_subnet_route_table_association_appliance2" {
  provider       = azurerm.appliance2
  subnet_id      = azurerm_subnet.azure_outbound_management2_subnet_appliance2.id
  route_table_id = azurerm_route_table.azure_outbound_management2_subnet_route_table_appliance2.id
}

resource "azurerm_subnet_route_table_association" "azure_private3_subnet_route_table_association_appliance2" {
  provider       = azurerm.appliance2
  subnet_id      = azurerm_subnet.azure_private3_subnet_appliance2.id
  route_table_id = azurerm_route_table.azure_private3_subnet_route_table_appliance2.id
}

resource "azurerm_subnet_route_table_association" "azure_global2_subnet_route_table_association_appliance2" {
  provider       = azurerm.appliance2
  subnet_id      = azurerm_subnet.azure_global2_subnet_appliance2.id
  route_table_id = azurerm_route_table.azure_global2_subnet_route_table_appliance2.id
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "diagnostics_storage_account_appliance2" {
  provider                 = azurerm.appliance2
  name                     = "shownet2021diag2"
  resource_group_name      = azurerm_resource_group.resource_group_appliance2.name
  location                 = lookup(var.azure_appliance2_common_parameter, "location")
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "azure_management2_subnet_nic_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-mgmt-2-nic"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name

  ip_configuration {
    name                          = "ip_configuration"
    subnet_id                     = azurerm_subnet.azure_management2_subnet_appliance2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.19.254"
  }
}
<#
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
resource "azurerm_linux_virtual_machine" "azure_management2_subnet_vm_appliance2" {
  name                  = "azure-mgmt-2-vm"
  provider              = azurerm.appliance2
  resource_group_name   = azurerm_resource_group.resource_group_appliance2.name
  location              = lookup(var.azure_appliance2_common_parameter, "location")
  network_interface_ids = [azurerm_network_interface.azure_management2_subnet_nic_appliance2.id]
  size                  = "Standard_B1s"
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics_storage_account_appliance2.primary_blob_endpoint
  }
  disable_password_authentication = "false"
  admin_username                  = var.strong_username
  admin_password                  = var.strong_password
  os_disk {
    caching              = "None"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "azure_outbound_management2_subnet_nic_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-ob-mgmt-2-nic"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name

  ip_configuration {
    name                          = "ip_configuration"
    subnet_id                     = azurerm_subnet.azure_outbound_management2_subnet_appliance2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.20.19.254"
  }
}

resource "azurerm_linux_virtual_machine" "azure_outbound_management2_subnet_vm_appliance2" {
  provider              = azurerm.appliance2
  name                  = "azure-ob-mgmt-2-vm"
  resource_group_name   = azurerm_resource_group.resource_group_appliance2.name
  location              = lookup(var.azure_appliance2_common_parameter, "location")
  network_interface_ids = [azurerm_network_interface.azure_outbound_management2_subnet_nic_appliance2.id]
  size                  = "Standard_B1s"
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics_storage_account_appliance2.primary_blob_endpoint
  }
  disable_password_authentication = "false"
  admin_username                  = var.strong_username
  admin_password                  = var.strong_password
  os_disk {
    caching              = "None"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "azure_private3_subnet_nic_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-private-3-nic"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name

  ip_configuration {
    name                          = "ip_configuration"
    subnet_id                     = azurerm_subnet.azure_private3_subnet_appliance2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.218.190"
  }
}

resource "azurerm_linux_virtual_machine" "azure_private3_subnet_vm_appliance2" {
  provider              = azurerm.appliance2
  name                  = "azure-private-3-vm"
  resource_group_name   = azurerm_resource_group.resource_group_appliance2.name
  location              = lookup(var.azure_appliance2_common_parameter, "location")
  network_interface_ids = [azurerm_network_interface.azure_private3_subnet_nic_appliance2.id]
  size                  = "Standard_B1s"
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics_storage_account_appliance2.primary_blob_endpoint
  }
  disable_password_authentication = "false"
  admin_username                  = var.strong_username
  admin_password                  = var.strong_password
  os_disk {
    caching              = "None"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "azure_global2_subnet_nic_appliance2" {
  provider            = azurerm.appliance2
  name                = "azure-global-2-nic"
  location            = lookup(var.azure_appliance2_common_parameter, "location")
  resource_group_name = azurerm_resource_group.resource_group_appliance2.name

  ip_configuration {
    name                          = "ip_configuration"
    subnet_id                     = azurerm_subnet.azure_global2_subnet_appliance2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.218.254"
  }
}

resource "azurerm_linux_virtual_machine" "azure_global2_subnet_vm_appliance2" {
  provider              = azurerm.appliance2
  name                  = "azure-global-2-vm"
  resource_group_name   = azurerm_resource_group.resource_group_appliance2.name
  location              = lookup(var.azure_appliance2_common_parameter, "location")
  network_interface_ids = [azurerm_network_interface.azure_global2_subnet_nic_appliance2.id]
  size                  = "Standard_B1s"
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics_storage_account_appliance2.primary_blob_endpoint
  }
  disable_password_authentication = "false"
  admin_username                  = var.strong_username
  admin_password                  = var.strong_password
  os_disk {
    caching              = "None"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
#>