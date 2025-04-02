module "oke_cluster" {
  source                       = "oracle-terraform-modules/oke/oci"
  version                      = "5.2.3"
  compartment_id               = local.oke_compartment_id
  tenancy_id                   = var.tenancy_id
  home_region                  = local.oke_home_region
  region                       = local.oke_region
  create_vcn                   = false
  vcn_id                       = local.vcn_id
  subnets                      = local.oke_subnets
  drg_id                       = local.oke_cluster_drg_id
  internet_gateway_route_rules = local.oke_cluster_igw_route_rules
  nat_gateway_route_rules      = local.oke_cluster_nat_route_rules
  bastion_image_id             = local.oke_bastion_image_id
  bastion_allowed_cidrs        = local.oke_bastion_allowed_cidrs
  operator_image_id            = local.oke_operator_image_id
  operator_install_k9s         = local.oke_operator_install_k9s
  cni_type                     = local.oke_cni_type
  cluster_name                 = local.oke_cluster_name
  cluster_type                 = local.oke_cluster_type
  kubernetes_version           = local.oke_kubernetes_version
  control_plane_is_public      = local.oke_control_plane_access
  allow_worker_ssh_access      = local.oke_allow_worker_ssh_access
  ssh_private_key              = local.oke_ssh_private_key
  ssh_public_key               = local.oke_ssh_public_key
  cluster_freeform_tags        = local.oke_tags
  tag_namespace                = local.oke_cluster_name
  worker_pools                 = local.oke_worker_pools
  state_id                     = local.oke_cluster_name
  allow_rules_public_lb        = local.oke_k8s_allow_rules_public_lb
  allow_rules_internal_lb      = local.oke_k8s_allow_rules_int_lb
  control_plane_allowed_cidrs  = local.oke_cluster_cp_allowed_cidrs
  cluster_addons               = local.oke_cluster_addons
  create_bastion               = false
  create_operator              = false
  create_iam_resources         = true
  create_iam_operator_policy   = "always"
  create_iam_worker_policy     = "always"
  create_iam_defined_tags      = false
  create_iam_tag_namespace     = false

  providers = {
    oci      = oci.current_region
    oci.home = oci.home
  }

}


### Added for observation cluster
module "obs_oke_cluster" {
  source                       = "oracle-terraform-modules/oke/oci"
  version                      = "5.2.3"
  compartment_id               = local.obs_oke_compartment_id
  tenancy_id                   = var.tenancy_id
  home_region                  = local.obs_oke_home_region
  region                       = local.obs_oke_region
  create_vcn                   = false
  vcn_id                       = local.vcn_id
  subnets                      = local.obs_oke_subnets
  drg_id                       = local.obs_oke_cluster_drg_id
  internet_gateway_route_rules = local.obs_oke_cluster_igw_route_rules
  nat_gateway_route_rules      = local.obs_oke_cluster_nat_route_rules
  bastion_image_id             = local.obs_oke_bastion_image_id
  bastion_allowed_cidrs        = local.obs_oke_bastion_allowed_cidrs
  operator_image_id            = local.obs_oke_operator_image_id
  operator_install_k9s         = local.obs_oke_operator_install_k9s
  cni_type                     = local.obs_oke_cni_type
  cluster_name                 = local.obs_oke_cluster_name
  cluster_type                 = local.obs_oke_cluster_type
  kubernetes_version           = local.obs_oke_kubernetes_version
  control_plane_is_public      = local.obs_oke_control_plane_access
  allow_worker_ssh_access      = local.obs_oke_allow_worker_ssh_access
  ssh_private_key              = local.obs_oke_ssh_private_key
  ssh_public_key               = local.obs_oke_ssh_public_key
  cluster_freeform_tags        = local.obs_oke_tags
  tag_namespace                = local.obs_oke_cluster_name
  worker_pools                 = local.obs_oke_worker_pools
  state_id                     = local.obs_oke_cluster_name
  allow_rules_public_lb        = local.obs_oke_k8s_allow_rules_public_lb
  allow_rules_internal_lb      = local.obs_oke_k8s_allow_rules_int_lb
  control_plane_allowed_cidrs  = local.obs_oke_cluster_cp_allowed_cidrs
  cluster_addons               = local.obs_oke_cluster_addons
  create_bastion               = false
  create_operator              = false
  create_iam_resources         = true
  create_iam_operator_policy   = "always"
  create_iam_worker_policy     = "always"
  create_iam_defined_tags      = false
  create_iam_tag_namespace     = false
  output_detail                = true

  providers = {
    oci      = oci.current_region
    oci.home = oci.home
  }
}