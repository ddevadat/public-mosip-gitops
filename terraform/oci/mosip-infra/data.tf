
data "oci_identity_tenancy" "tenant_details" {
  tenancy_id = var.tenancy_id
}

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenant_details.home_region_key]
  }
}

data "oci_core_images" "bastion_images" {
  compartment_id           = var.compartment_id
  operating_system         = var.bastion_os
  operating_system_version = var.bastion_os_version
  shape                    = var.bastion_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


data "oci_core_images" "operator_images" {
  compartment_id           = var.compartment_id
  operating_system         = var.operator_os
  operating_system_version = var.operator_os_version
  shape                    = var.operator_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}



data "oci_containerengine_cluster_option" "oke" {
  cluster_option_id = "all"
}

# data "oci_containerengine_addon_options" "k8s_addon_options" {
#   kubernetes_version = local.k8s_latest_version
# }