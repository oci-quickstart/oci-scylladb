data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = "${var.compartment_ocid}"
}

resource "oci_core_virtual_network" "virtual_network" {
  display_name   = "virtual_network"
  compartment_id = "${var.compartment_ocid}"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "scylladb"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  display_name   = "internet_gateway"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.virtual_network.id}"
}

resource "oci_core_route_table" "route_table" {
  display_name   = "route_table"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.virtual_network.id}"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.internet_gateway.id}"
  }
}

resource "oci_core_subnet" "subnet" {
  display_name        = "subnet"
  compartment_id      = "${var.compartment_ocid}"
  cidr_block          = "10.0.1.0/24"
  vcn_id              = "${oci_core_virtual_network.virtual_network.id}"
  route_table_id      = "${oci_core_route_table.route_table.id}"
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.virtual_network.default_dhcp_options_id}"
  dns_label           = "scylladb"
}
