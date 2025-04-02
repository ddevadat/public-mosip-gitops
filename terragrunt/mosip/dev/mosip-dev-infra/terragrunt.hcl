terraform {
source = "git::${get_env("IAC_TERRAFORM_MODULES_REPO")}//terraform/oci/mosip-infra?ref=${get_env("IAC_TERRAFORM_MODULES_TAG")}"
}


generate "required_providers_override" {
  path = "required_providers_override.tf"

  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform { 
  
  required_providers {
    %{if get_env("CONTROL_CENTER_CLOUD_PROVIDER") == "oci"}
    oci = {
      source  = "oracle/oci"
      version = "${local.cloud_platform_vars.oci_provider_version}"
    }
    %{endif}
  }
}
%{if get_env("CONTROL_CENTER_CLOUD_PROVIDER") == "oci"}
provider "oci" {
  region           = "${local.env_vars.region}"
  # auth             = "InstancePrincipal"
}
%{endif}
EOF
}


inputs = {
  env                          = local.env_vars.env
  region                       = local.env_vars.region
  home_region                  = local.env_vars.home_region
  domain                       = local.env_vars.domain
  tenancy_id                   = local.env_vars.tenancy_id
  compartment_id               = local.env_vars.compartment_id
  vault_id                     = local.env_vars.vault_id
  vault_enc_key_id             = local.env_vars.vault_enc_key_id
  k8s_cluster_properties       = local.env_vars.k8s_cluster_properties
  tags                         = local.tags
}

locals {
  env_vars = yamldecode(
    file("${find_in_parent_folders("environment.yaml")}")
  )
  cloud_platform_vars = yamldecode(
    file("${find_in_parent_folders("${get_env("CONTROL_CENTER_CLOUD_PROVIDER")}-vars.yaml")}")
  )
  tags = local.env_vars.tags
}

include "root" {
  path = find_in_parent_folders()
}