output "workload" {
  value = {
    compute_ssh_key   = base64encode(local.bastion_ssh_private_key)
    bastion_public_ip = module.operator.public_ip
    operator_hosts_maps = {
      operator = module.operator.private_ip
    }
    operator_hosts_var_maps = {
      workload_name                    = var.workload_name
      tenancy_id                       = var.tenancy_id
      compartment_id                   = var.compartment_id
      zone_compartment_id              = var.compartment_id
      vault_compartment_id             = var.compartment_id
      vault_id                         = var.vault_id
      vault_key_id                     = var.vault_enc_key_id
      region                           = var.region
      oke_k8s_cluster_id               = module.oke_cluster.cluster_id
      oke_obs_cluster_id               = module.obs_oke_cluster.cluster_id
      oke_k8s_cluster_endpoint         = module.oke_cluster.cluster_endpoints.private_endpoint
      oke_obs_cluster_endpoint         = module.obs_oke_cluster.cluster_endpoints.private_endpoint
      oke_k8s_cluster_name             = local.oke_cluster_name
      oke_obs_cluster_name             = local.obs_oke_cluster_name
      application_repo                 = var.application_repo
      certificate_email                = var.certificate_email
      domain                           = var.domain
      env                              = var.env
      acme_server                      = local.acme_server
      public_lb_subnet_id              = module.oke_cluster.pub_lb_subnet_id
      public_lb_nsg_id                 = module.oke_cluster.pub_lb_nsg_id
      private_lb_subnet_id             = module.oke_cluster.int_lb_subnet_id
      private_lb_nsg_id                = module.oke_cluster.int_lb_nsg_id
      lb_subnet_id_oke_k8s_cluster     = module.oke_cluster.pub_lb_subnet_id
      nsg_lb_oke_k8s_cluster           = module.oke_cluster.pub_lb_nsg_id
      lb_subnet_id_oke_obs_cluster     = module.obs_oke_cluster.pub_lb_subnet_id
      nsg_lb_oke_obs_cluster           = module.obs_oke_cluster.pub_lb_nsg_id
      lb_int_subnet_id_oke_k8s_cluster = module.oke_cluster.int_lb_subnet_id
      nsg_int_lb_oke_k8s_cluster       = module.oke_cluster.int_lb_nsg_id
      lb_int_subnet_id_oke_obs_cluster = module.obs_oke_cluster.int_lb_subnet_id
      nsg_int_lb_oke_obs_cluster       = module.obs_oke_cluster.int_lb_nsg_id
      ocir_user                        = oci_identity_user.ocir_user.name
      ocir_token                       = oci_identity_auth_token.ocir_user_auth_token.token
      bastion_public_ip                = module.operator.public_ip
    }
  }
  sensitive = true
}
