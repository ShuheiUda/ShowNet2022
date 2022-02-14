########################################
### OCI.tf
########################################
### Interop Tokyo 2021
### ShowNet Cloud NOC
###  Ryosuke Kato
###  Mami Nakamura
###  Shuhei Uda
########################################

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs
provider "oci" {
  private_key = var.private_key
}

variable "private_key" {}
variable "ssh_public_key" {}

variable "oracle_general" {
  type = map(any)
  default = {
    #"compartment_ocid"    = "ocid1.compartment.oc1..aaaaaaaamrfplnh3eqsrdl6wtuamuwl7jqxksxvllb3qjsbrl62lxqpwimhq"
    #"availability_domain" = "YZYQ:AP-TOKYO-1-AD-1"
    "compartment_ocid"    = "ocid1.compartment.oc1..aaaaaaaa357tins5borz4z6vtcfrqtgll5hy567p637wdlgxondvlqygh2eq"
    "availability_domain" = "sBzN:CA-TORONTO-1-AD-1"
  }
}

variable "oracle_vcn_parameter" {
  type = map(any)
  default = {
    "management_subnet_address_prefixes"          = "172.16.19.64/26"
    "outbound_management_subnet_address_prefixes" = "172.20.19.64/26"
    "private1_subnet_address_prefixes"            = "10.0.216.128/26"
    "private2_subnet_address_prefixes"            = "10.0.216.192/27"
    "global_subnet_address_prefixes"              = "10.0.216.224/27"
  }
}

variable "oracle_virtual_circuit_parameter" {
  type = map(any)
  default = {
    "oracle_bgp_peering_subnet1"   = "10.0.219.48/30"
    "oracle_bgp_peering_subnet2"   = "10.0.219.52/30"
    "oracle_bgp_peering_ip1"   = "10.0.219.49/30"
    "oracle_bgp_peering_ip2"   = "10.0.219.53/30"
    "customer_bgp_peering_ip1" = "10.0.219.50/30"
    "customer_bgp_peering_ip2" = "10.0.219.54/30"
  }
}
/*
#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn
resource "oci_core_vcn" "oracle_vcn" {
  display_name   = "vcn"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  cidr_blocks = [
    lookup(var.oracle_vcn_parameter, "management_subnet_address_prefixes"),
    lookup(var.oracle_vcn_parameter, "outbound_management_subnet_address_prefixes"),
    lookup(var.oracle_vcn_parameter, "private1_subnet_address_prefixes"),
    lookup(var.oracle_vcn_parameter, "private2_subnet_address_prefixes"),
    lookup(var.oracle_vcn_parameter, "global_subnet_address_prefixes")
  ]
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_subnet
resource "oci_core_subnet" "management_subnet" {
  display_name               = "oci-mgmt"
  compartment_id             = lookup(var.oracle_general, "compartment_ocid")
  cidr_block                 = lookup(var.oracle_vcn_parameter, "management_subnet_address_prefixes")
  vcn_id                     = oci_core_vcn.oracle_vcn.id
  route_table_id             = oci_core_route_table.management_subnet_route_table.id
  security_list_ids          = [oci_core_security_list.management_subnet_security_list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "outbound_management_subnet" {
  display_name               = "oci-ob-mgmt"
  compartment_id             = lookup(var.oracle_general, "compartment_ocid")
  cidr_block                 = lookup(var.oracle_vcn_parameter, "outbound_management_subnet_address_prefixes")
  vcn_id                     = oci_core_vcn.oracle_vcn.id
  route_table_id             = oci_core_route_table.outbound_management_subnet_route_table.id
  security_list_ids          = [oci_core_security_list.outbound_management_subnet_security_list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "private1_subnet" {
  display_name               = "oci-private-1"
  compartment_id             = lookup(var.oracle_general, "compartment_ocid")
  cidr_block                 = lookup(var.oracle_vcn_parameter, "private1_subnet_address_prefixes")
  vcn_id                     = oci_core_vcn.oracle_vcn.id
  route_table_id             = oci_core_route_table.private1_subnet_route_table.id
  security_list_ids          = [oci_core_security_list.private1_subnet_security_list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "global_subnet" {
  display_name               = "oci-global"
  compartment_id             = lookup(var.oracle_general, "compartment_ocid")
  cidr_block                 = lookup(var.oracle_vcn_parameter, "global_subnet_address_prefixes")
  vcn_id                     = oci_core_vcn.oracle_vcn.id
  route_table_id             = oci_core_route_table.global_subnet_route_table.id
  security_list_ids          = [oci_core_security_list.global_subnet_security_list.id]
  prohibit_public_ip_on_vnic = false
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg
resource "oci_core_drg" "oracle_drg" {
  display_name   = "drg"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table
resource "oci_core_route_table" "management_subnet_route_table" {
  display_name   = "oci-mgmt-route-table"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  route_rules {
    destination       = "172.16.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.oracle_drg.id
  }
}

resource "oci_core_route_table" "outbound_management_subnet_route_table" {
  display_name   = "oci-ob-mgmt-route-table"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  route_rules {
    destination       = "172.20.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.oracle_drg.id
  }
}

resource "oci_core_route_table" "private1_subnet_route_table" {
  display_name   = "oci-private-1-route-table"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  route_rules {
    destination       = "10.0.0.0/8"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.oracle_drg.id
  }
}

resource "oci_core_route_table" "global_subnet_route_table" {
  display_name   = "oci-global-route-table"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oracle_internet_gateway.id
  }
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list
resource "oci_core_security_list" "management_subnet_security_list" {
  display_name   = "oci-mgmt-security-list"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  egress_security_rules {
    protocol    = "all"
    destination = "172.16.0.0/16"
    description = "allow_management_outbound"
  }
  ingress_security_rules {
    protocol    = "all"
    source      = "172.16.0.0/16"
    description = "allow_management_inbound"
  }
}

resource "oci_core_security_list" "outbound_management_subnet_security_list" {
  display_name   = "oci-ob-mgmt-security-list"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "allow_outbound_management_outbound"
  }
  ingress_security_rules {
    protocol    = "all"
    source      = "172.20.0.0/16"
    description = "allow_outbound_management_inbound"
  }
}

resource "oci_core_security_list" "private1_subnet_security_list" {
  display_name   = "oci-private-1-security-list"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  egress_security_rules {
    protocol    = "all"
    destination = "10.0.0.0/8"
    description = "allow_private_outbound"
  }
  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.0.0/8"
    description = "allow_private_inbound"
  }
}

resource "oci_core_security_list" "global_subnet_security_list" {
  display_name   = "oci-global-security-list"
  compartment_id = lookup(var.oracle_general, "compartment_ocid")
  vcn_id         = oci_core_vcn.oracle_vcn.id
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "allow_global_outbound"
  }
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg_attachment
resource "oci_core_drg_attachment" "oracle_drg_attachment" {
  drg_id = oci_core_drg.oracle_drg.id
  vcn_id = oci_core_vcn.oracle_vcn.id
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_virtual_circuit
resource "oci_core_virtual_circuit" "azure" {
  compartment_id       = lookup(var.oracle_general, "compartment_ocid")
  type                 = "PRIVATE"
  bandwidth_shape_name = "1 Gbps"

  cross_connect_mappings {
    customer_bgp_peering_ip = lookup(var.oracle_virtual_circuit_parameter, "customer_bgp_peering_ip1")
    oracle_bgp_peering_ip   = lookup(var.oracle_virtual_circuit_parameter, "oracle_bgp_peering_ip1")
  }
  cross_connect_mappings {
    customer_bgp_peering_ip = lookup(var.oracle_virtual_circuit_parameter, "customer_bgp_peering_ip2")
    oracle_bgp_peering_ip   = lookup(var.oracle_virtual_circuit_parameter, "oracle_bgp_peering_ip2")
  }
  display_name              = "fastconnect"
  gateway_id                = oci_core_drg.oracle_drg.id
  #provider_service_id       = "ocid1.providerservice.oc1.ap-tokyo-1.aaaaaaaaea5dqs2zg7ecvenqai6yhfm4idgseycgkgtqjkbbcvul2tnsprwa"
  provider_service_id       = "ocid1.providerservice.oc1.ca-toronto-1.aaaaaaaatxossip3saeh5sozegt6vxujl3ya6vvkja76b3ccgpsm5kyb4imq"
  provider_service_key_name = azurerm_express_route_circuit.expressroute_circuit_oci.service_key
}

#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway
resource "oci_core_internet_gateway" "oracle_internet_gateway" {
    compartment_id = lookup(var.oracle_general, "compartment_ocid")
    vcn_id         = oci_core_vcn.oracle_vcn.id
    display_name   = "internet-gateway"
}
/*
#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance
resource "oci_core_instance" "management_subnet_instance" {
  display_name        = "oci-mgmt-vm"
  compartment_id      = lookup(var.oracle_general, "compartment_ocid")
  availability_domain = lookup(var.oracle_general, "availability_domain")
  shape               = "VM.Standard.E2.1"
  create_vnic_details {
    assign_public_ip = "false"
    private_ip       = "172.16.19.126"
    subnet_id        = oci_core_subnet.management_subnet.id
  }
  source_details {
    source_id   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaawhdx5rbtwudra22xj7p65z4vspm6vr2wilofy5ovqi34i6ymwwtq"
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "outbound_management_subnet_instance" {
  display_name        = "oci-ob-mgmt-vm"
  compartment_id      = lookup(var.oracle_general, "compartment_ocid")
  availability_domain = lookup(var.oracle_general, "availability_domain")
  shape               = "VM.Standard.E2.1"
  create_vnic_details {
    assign_public_ip = "false"
    private_ip       = "172.20.19.126"
    subnet_id        = oci_core_subnet.outbound_management_subnet.id
  }
  source_details {
    source_id   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaawhdx5rbtwudra22xj7p65z4vspm6vr2wilofy5ovqi34i6ymwwtq"
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "private1_subnet_instance" {
  display_name        = "oci-private-1-vm"
  compartment_id      = lookup(var.oracle_general, "compartment_ocid")
  availability_domain = lookup(var.oracle_general, "availability_domain")
  shape               = "VM.Standard.E2.1"
  create_vnic_details {
    assign_public_ip = "false"
    private_ip       = "10.0.216.190"
    subnet_id        = oci_core_subnet.private1_subnet.id
  }
  source_details {
    source_id   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaawhdx5rbtwudra22xj7p65z4vspm6vr2wilofy5ovqi34i6ymwwtq"
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  preserve_boot_volume = false
}

resource "oci_core_instance" "global_subnet_instance" {
  display_name        = "oci-global-vm"
  compartment_id      = lookup(var.oracle_general, "compartment_ocid")
  availability_domain = lookup(var.oracle_general, "availability_domain")
  shape               = "VM.Standard.E2.1"
  create_vnic_details {
    assign_public_ip = "true"
    subnet_id        = oci_core_subnet.global_subnet.id
  }
  source_details {
    source_id   = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaawhdx5rbtwudra22xj7p65z4vspm6vr2wilofy5ovqi34i6ymwwtq"
    source_type = "image"
  }
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  preserve_boot_volume = false
}
*/