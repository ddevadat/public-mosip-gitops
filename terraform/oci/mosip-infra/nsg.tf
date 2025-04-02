resource "oci_core_network_security_group_security_rule" "rancher_k8s_egress" {
  network_security_group_id = module.oke_cluster.control_plane_nsg_id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = module.obs_oke_cluster.worker_nsg_id
  description               = "Rancher to MOSIP Communication"
  destination_type          = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "rancher_k8s_ingress" {
  network_security_group_id = module.oke_cluster.control_plane_nsg_id
  direction                 = "INGRESS"
  description               = "Rancher to MOSIP Communication"
  protocol                  = "6"
  source                    = module.obs_oke_cluster.worker_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
}


resource "oci_core_network_security_group_security_rule" "rancher_https_ingress" {
  network_security_group_id = module.obs_oke_cluster.worker_nsg_id
  direction                 = "INGRESS"
  description               = "Rancher https access"
  protocol                  = "6"
  source                    = module.obs_oke_cluster.pub_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  tcp_options {
    destination_port_range {
      max = "443"
      min = "443"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "rancher_http_ingress" {
  network_security_group_id = module.obs_oke_cluster.worker_nsg_id
  direction                 = "INGRESS"
  description               = "Rancher http access"
  protocol                  = "6"
  source                    = module.obs_oke_cluster.pub_lb_nsg_id
  source_type               = "NETWORK_SECURITY_GROUP"
  tcp_options {
    destination_port_range {
      max = "80"
      min = "80"
    }
  }
}