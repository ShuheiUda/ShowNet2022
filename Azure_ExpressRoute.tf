########################################
### Azure_ExpressRoute.tf
########################################
### Interop Tokyo 2021
### ShowNet Cloud NOC
###  Ryosuke Kato
###  Mami Nakamura
###  Shuhei Uda
########################################

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  alias           = "expressroute"
  subscription_id = "49dde45f-5712-44b2-b0ab-296bde83af6b"
  features {}
}

variable "azure_expressroute_common_parameter" {
  type = map(any)
  default = {
    "location"            = "japaneast"
    "resource_group_name" = "cloud-noc-managed-expressroute"
  }
}

variable "expressroute_circuit_common_parameter" {
  type = map(any)
  default = {
    "peering_location"  = "tokyo"
    "bandwidth_in_mbps" = "50"
    "sku_tier"          = "Standard" #本番は Premium に変更予定
    "sku_family"        = "MeteredData"
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "resource_group_expressroute" {
  provider = azurerm.expressroute
  name     = lookup(var.azure_expressroute_common_parameter, "resource_group_name")
  location = lookup(var.azure_expressroute_common_parameter, "location")
}


#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit
resource "azurerm_express_route_circuit" "expressroute_circuit_fic" {
  provider              = azurerm.expressroute
  name                  = "fic"
  resource_group_name   = azurerm_resource_group.resource_group_expressroute.name
  location              = lookup(var.azure_expressroute_common_parameter, "location")
  service_provider_name = "NTT Communications - Flexible InterConnect"
  peering_location      = lookup(var.expressroute_circuit_common_parameter, "peering_location")
  bandwidth_in_mbps     = lookup(var.expressroute_circuit_common_parameter, "bandwidth_in_mbps")
  sku {
    tier   = lookup(var.expressroute_circuit_common_parameter, "sku_tier")
    family = lookup(var.expressroute_circuit_common_parameter, "sku_family")
  }
}
/*
resource "azurerm_express_route_circuit" "expressroute_circuit_dcconnect" {
  provider              = azurerm.expressroute
  name                  = "dc-connect"
  resource_group_name   = azurerm_resource_group.resource_group_expressroute.name
  location              = lookup(var.azure_expressroute_common_parameter, "location")
  service_provider_name = "Equinix"
  peering_location      = lookup(var.expressroute_circuit_common_parameter, "peering_location")
  bandwidth_in_mbps     = lookup(var.expressroute_circuit_common_parameter, "bandwidth_in_mbps")
  sku {
    tier   = lookup(var.expressroute_circuit_common_parameter, "sku_tier")
    family = lookup(var.expressroute_circuit_common_parameter, "sku_family")
  }
}

resource "azurerm_express_route_circuit" "expressroute_circuit_megaport" {
  provider              = azurerm.expressroute
  name                  = "megaport"
  resource_group_name   = azurerm_resource_group.resource_group_expressroute.name
  location              = lookup(var.azure_expressroute_common_parameter, "location")
  service_provider_name = "Megaport"
  peering_location      = lookup(var.expressroute_circuit_common_parameter, "peering_location")
  bandwidth_in_mbps     = lookup(var.expressroute_circuit_common_parameter, "bandwidth_in_mbps")
  sku {
    tier   = lookup(var.expressroute_circuit_common_parameter, "sku_tier")
    family = lookup(var.expressroute_circuit_common_parameter, "sku_family")
  }
}
*/

resource "azurerm_express_route_circuit" "expressroute_circuit_oci" {
  provider              = azurerm.expressroute
  name                  = "oci"
  resource_group_name   = azurerm_resource_group.resource_group_expressroute.name
  location              = lookup(var.azure_expressroute_common_parameter, "location")
  service_provider_name = "Oracle Cloud FastConnect"
  peering_location      = lookup(var.expressroute_circuit_common_parameter, "peering_location")
  bandwidth_in_mbps     = lookup(var.expressroute_circuit_common_parameter, "bandwidth_in_mbps")
  sku {
    tier   = lookup(var.expressroute_circuit_common_parameter, "sku_tier")
    family = lookup(var.expressroute_circuit_common_parameter, "sku_family")
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_authorization
resource "azurerm_express_route_circuit_authorization" "expressroute_circuit_oci_authorization" {
  provider                   = azurerm.expressroute
  name                       = "expressroute_oci_auth"
  express_route_circuit_name = azurerm_express_route_circuit.expressroute_circuit_oci.name
  resource_group_name        = azurerm_resource_group.resource_group_expressroute.name
}
