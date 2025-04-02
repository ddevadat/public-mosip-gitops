data "oci_identity_availability_domains" "all" {
  compartment_id = var.compartment_id
}

locals {

  ads = data.oci_identity_availability_domains.all.availability_domains

  // Map of parsed availability domain numbers to tenancy-specific names
  // Used by resources with AD placement for generic selection
  ad_numbers_to_names = local.ads != null ? {
    for ad in local.ads : parseint(substr(ad.name, -1, -1), 10) => ad.name
  } : { -1 : "" } # Fallback handles failure when unavailable but not required

  // List of availability domain numbers in region
  // Used to intersect desired AD lists against presence in region
  ad_numbers = local.ads != null ? sort(keys(local.ad_numbers_to_names)) : []

  kubeconfig_private = module.obs_oke_cluster.cluster_kubeconfig
}

module "operator" {
  source         = "./modules/operator"
  state_id       = "mosipdoc"
  compartment_id = var.compartment_id

  # Operator
  availability_domain = coalesce(var.operator_availability_domain, lookup(local.ad_numbers_to_names, local.ad_numbers[0]))
  image_id            = local.operator_image_id
  # kubeconfig          = yamlencode(local.kubeconfig_private)
  kubernetes_version = local.k8s_latest_version
  nsg_ids            = [oci_core_network_security_group.bastion.id]
  ssh_private_key    = base64decode(var.ssh_private_key)
  ssh_public_key     = var.ssh_public_key
  subnet_id          = local.public_subnet_id
  freeform_tags      = var.tags
}