
# provider "oci" {
#   alias  = "home_region"
#   region = lookup(data.oci_identity_regions.home_region.regions[0], "name")
# }

provider "oci" {
  alias        = "current_region"
  region       = var.region
  user_ocid    = var.user_ocid
  tenancy_ocid = var.tenancy_id
  private_key  = var.private_key
  fingerprint  = var.fingerprint
}

provider "oci" {
  alias        = "home"
  region       = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  user_ocid    = var.user_ocid
  tenancy_ocid = var.tenancy_id
  private_key  = var.private_key
  fingerprint  = var.fingerprint
}