
locals {
  vcn_subnet_maps     = lookup(var.vcn_properties, "subnet_maps")
  vcn_cidr_list       = lookup(var.vcn_properties, "vcn_cidr")
  vcn_name            = lookup(var.vcn_properties, "vcn_name", "mosipdoc")
  vcn_id              = module.vcn.vcn_id
  public_subnet_id    = module.vcn.subnet_id.public-subnet
  private_subnet_id   = module.vcn.subnet_id.private-subnet
  oke_cp_subnet_id    = module.vcn.subnet_id.oke-control-plane
  public_subnet_cidr  = module.vcn.subnet_all_attributes.public_sub1.cidr_block
  private_subnet_cidr = module.vcn.subnet_all_attributes.private_sub1.cidr_block
  oke_cp_subnet_cidr  = module.vcn.subnet_all_attributes.private_sub2.cidr_block
}

module "vcn" {
  source                   = "oracle-terraform-modules/vcn/oci"
  version                  = "3.6.0"
  compartment_id           = var.compartment_id
  create_internet_gateway  = true
  create_nat_gateway       = true
  create_service_gateway   = true
  freeform_tags            = merge({}, var.tags)
  subnets                  = local.vcn_subnet_maps
  vcn_cidrs                = local.vcn_cidr_list
  vcn_name                 = local.vcn_name
  lockdown_default_seclist = false
}


resource "oci_core_network_security_group" "bastion" {
  compartment_id = var.compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${local.vcn_name}-bastion"
}


resource "oci_core_network_security_group_security_rule" "bastion_ssh" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
    source_port_range {
      max = 22
      min = 22
    }
  }
}


resource "oci_core_network_security_group_security_rule" "bastion_wireguard_udp" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "INGRESS"
  description               = "wireguard client access"
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = 51820
      min = 51820
    }
  }
}


resource "oci_core_network_security_group_security_rule" "bastion_wireguard_tcp" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "INGRESS"
  description               = "wireguard client access"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 51820
      min = 51820
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_egress_all" {
  network_security_group_id = oci_core_network_security_group.bastion.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}


