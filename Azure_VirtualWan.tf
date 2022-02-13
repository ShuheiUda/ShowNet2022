########################################
### Azure_VirtualWAN.tf
########################################
### Interop Tokyo 2021
### ShowNet Cloud NOC
###  Ryosuke Kato
###  Mami Nakamura
###  Shuhei Uda
########################################

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  subscription_id = "49dde45f-5712-44b2-b0ab-296bde83af6b"
  features {}
}

variable "strong_username" {}
variable "strong_password" {}
variable "admin_password" {}

variable "azure_vwan_common_parameter" {
  type = map(any)
  default = {
    "location"            = "japaneast"
    "resource_group_name" = "cloud-noc-managed-vwan"
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "resource_group_main" {
  name     = lookup(var.azure_vwan_common_parameter, "resource_group_name")
  location = lookup(var.azure_vwan_common_parameter, "location")
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan
resource "azurerm_virtual_wan" "virtual_wan" {
  name                = "azure-virtual-wan"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub
resource "azurerm_virtual_hub" "virtual_hub" {
  name                = "azure-virtual-hub"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan.id
  address_prefix      = "172.16.29.0/24"
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway
resource "azurerm_vpn_gateway" "vpn_gateway" {
  name                = "azure-vpn-gateway"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_hub_id      = azurerm_virtual_hub.virtual_hub.id
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection
resource "azurerm_virtual_hub_connection" "virtual_hub_connection_appliance1" {
  name                      = "azure-connection-appliance1"
  virtual_hub_id            = azurerm_virtual_hub.virtual_hub.id
  remote_virtual_network_id = azurerm_virtual_network.vnet_appliance1.id
}

resource "azurerm_virtual_hub_connection" "virtual_hub_connection_appliance2" {
  name                      = "azure-connection-appliance2"
  virtual_hub_id            = azurerm_virtual_hub.virtual_hub.id
  remote_virtual_network_id = azurerm_virtual_network.vnet_appliance2.id
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_site
resource "azurerm_vpn_site" "vpn_site_makuhari" {
  name                = "makuhari"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan.id
  link {
    name       = "fg600e"
    ip_address = "45.0.192.116"
    bgp {
      asn             = "65001"
      peering_address = "172.16.255.254"
    }
  }
  link {
    name       = "fg100f"
    ip_address = "202.222.13.42"
    bgp {
      asn             = "65001"
      peering_address = "10.0.219.72"
    }
  }
}

resource "azurerm_vpn_site" "vpn_site_gcp_management" {
  name                = "gcp-mgmt"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan.id
  address_cidrs       = ["172.16.19.128/26"]
  link {
    name       = "classic-vpn-gateway-mgmt"
    ip_address = google_compute_address.vpn_static_ip_management.address
  }
}

resource "azurerm_vpn_site" "vpn_site_gcp_outbound_management" {
  name                = "gcp-ob-mgmt"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan.id
  address_cidrs       = ["172.20.19.128/26"]
  link {
    name       = "classic-vpn-gateway-ob-mgmt"
    ip_address = google_compute_address.vpn_static_ip_outbound_management.address
  }
}

resource "azurerm_vpn_site" "vpn_site_ecl" {
  name                = "ecl"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan.id
  link {
    name       = "srx"
    ip_address = "153.128.125.212"
    bgp {
      asn             = "65002"
      peering_address = "10.0.219.73"
    }
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway_connection
resource "azurerm_vpn_gateway_connection" "vpn_gateway_connection_makuhari" {
  name               = "connection-makuhari"
  vpn_gateway_id     = azurerm_vpn_gateway.vpn_gateway.id
  remote_vpn_site_id = azurerm_vpn_site.vpn_site_makuhari.id
  vpn_link {
    name             = "makuhari"
    vpn_site_link_id = azurerm_vpn_site.vpn_site_makuhari.link[0].id
    bandwidth_mbps   = "1000"
    bgp_enabled      = "true"
    shared_key       = var.admin_password
  }
}

resource "azurerm_vpn_gateway_connection" "vpn_gateway_connection_gcp_management" {
  name               = "connection-gcp-mgmt"
  vpn_gateway_id     = azurerm_vpn_gateway.vpn_gateway.id
  remote_vpn_site_id = azurerm_vpn_site.vpn_site_gcp_management.id
  vpn_link {
    name             = "gcp-mgmt"
    vpn_site_link_id = azurerm_vpn_site.vpn_site_gcp_management.link[0].id
    bandwidth_mbps   = "1000"
    shared_key       = var.admin_password
  }
}

resource "azurerm_vpn_gateway_connection" "vpn_gateway_connection_gcp_outbound_management" {
  name               = "connection-gcp-ob-mgmt"
  vpn_gateway_id     = azurerm_vpn_gateway.vpn_gateway.id
  remote_vpn_site_id = azurerm_vpn_site.vpn_site_gcp_outbound_management.id
  vpn_link {
    name             = "gcp-ob-mgmt"
    vpn_site_link_id = azurerm_vpn_site.vpn_site_gcp_outbound_management.link[0].id
    bandwidth_mbps   = "1000"
    shared_key       = var.admin_password
  }
}

resource "azurerm_vpn_gateway_connection" "vpn_gateway_connection_ecl" {
  name               = "connection-ecl"
  vpn_gateway_id     = azurerm_vpn_gateway.vpn_gateway.id
  remote_vpn_site_id = azurerm_vpn_site.vpn_site_ecl.id
  vpn_link {
    name             = "ecl"
    vpn_site_link_id = azurerm_vpn_site.vpn_site_ecl.link[0].id
    bandwidth_mbps   = "1000"
    bgp_enabled      = "true"
    shared_key       = var.admin_password
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_gateway
resource "azurerm_express_route_gateway" "express_route_gateway" {
  name                = "azure-express-route-gateway"
  resource_group_name = azurerm_resource_group.resource_group_main.name
  location            = lookup(var.azure_vwan_common_parameter, "location")
  virtual_hub_id      = azurerm_virtual_hub.virtual_hub.id
  scale_units         = 1
}