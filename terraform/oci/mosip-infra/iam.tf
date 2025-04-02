resource "oci_identity_policy" "workload_policy" {
  name           = "${local.oke_cluster_name}-workload-policies"
  description    = "Policies for workload (${local.oke_cluster_name})"
  compartment_id = var.compartment_id
  statements     = local.mosip_policy
}


resource "oci_identity_user" "ocir_user" {
  #Required
  compartment_id = var.tenancy_id
  description    = "User created for ocir access from oke cluster ${local.oke_cluster_name}"
  name           = "ocir-user-${local.oke_cluster_name}"
  email          = var.ocir_user_email
  provider       = oci.home
}

resource "oci_identity_user_capabilities_management" "ocir_user_capabilities_management" {
  #Required
  user_id = oci_identity_user.ocir_user.id

  #Optional 
  can_use_api_keys             = "true"
  can_use_auth_tokens          = "true"
  can_use_console_password     = "false"
  can_use_customer_secret_keys = "true"
  can_use_smtp_credentials     = "true"
}


resource "oci_identity_user_group_membership" "ocir_user_group_membership" {
  #Required
  group_id = oci_identity_group.ocir_group.id
  user_id  = oci_identity_user.ocir_user.id
}

resource "oci_identity_group" "ocir_group" {
  #Required
  compartment_id = var.tenancy_id
  description    = "Group created for ocir access from oke cluster ${local.oke_cluster_name}"
  name           = "ocir-group-${local.oke_cluster_name}"
  provider       = oci.home
}


resource "oci_identity_policy" "ocir_policies" {
  name           = "${local.oke_cluster_name}-ocir-policies"
  description    = "OCIR Policies for (${local.oke_cluster_name})"
  compartment_id = var.compartment_id
  statements     = local.ocir_policy_statements
}

resource "oci_identity_api_key" "ocir_user_api_key" {
  #Required
  key_value = tls_private_key.oci_api_key.public_key_pem
  user_id   = oci_identity_user.ocir_user.id
}

resource "oci_identity_auth_token" "ocir_user_auth_token" {
  description = "Auth Token for OCIR operation"
  user_id     = oci_identity_user.ocir_user.id
}