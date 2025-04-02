



locals {
  bastion_image_id              = lookup(data.oci_core_images.bastion_images.images[0], "id")
  operator_image_id             = lookup(data.oci_core_images.operator_images.images[0], "id")
  home_region                   = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  k8s_latest_version            = reverse(sort(data.oci_containerengine_cluster_option.oke.kubernetes_versions))[0]
  acme_server                   = (var.ssl_cert_type == "prod") ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
  default_cloud_init_merge_type = "list(append)+dict(no_replace,recurse_list)+str(append)"
  cp_allowed_cidrs              = ["${local.private_subnet_cidr}", "${local.public_subnet_cidr}"]

}

locals {
  default_worker_pools = {
    workload = {
      create           = true
      mode             = "node-pool",
      size             = 6,
      shape            = "VM.Standard.E4.Flex",
      ocpus            = 4,
      memory           = 32,
      boot_volume_size = 100,
      node_labels = {
        "project"                       = "workload",
        "oke.oraclecloud.com/pool.name" = "workload"
      },
      disable_default_cloud_init = true,
      cloud_init = [
        {
          content      = jsonencode({ timezone = "Etc/UTC" })
          content_type = "text/cloud-config",
          filename     = "10-timezone.yml"
        },
        {
          content = jsonencode({
            # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#growpart
            growpart = {
              mode                     = "auto"
              devices                  = ["/"]
              ignore_growroot_disabled = false
            }

            # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#resizefs
            resize_rootfs = true

            # Resize logical LVM root volume when utility is present
            bootcmd = ["if [[ -f /usr/libexec/oci-growfs ]]; then /usr/libexec/oci-growfs -y; fi"]
          })
          content_type = "text/cloud-config",
          filename     = "10-growpart.yml"
        },
        {
          content = jsonencode({
            write_files = [
              {
                content = module.oke_cluster.apiserver_private_host
                path    = "/etc/oke/oke-apiserver"
              },
              {
                content  = module.oke_cluster.cluster_ca_cert
                encoding = "base64"
                path     = "/etc/kubernetes/ca.crt"
              },
            ]
          })
          content_type = "text/cloud-config",
          filename     = "50-oke-config.yml"
          merge_type   = "list(append)+dict(no_replace,recurse_list)+str(append)"
        },
        {
          content      = <<-EOT
          runcmd:
          - mkdir -p /root/.oci/
          - echo ${base64encode(nonsensitive(tls_private_key.oci_api_key.private_key_pem))} | base64 -d > /root/.oci/api.key
          - chmod 600 /root/.oci/api.key
          - echo "[DEFAULT]" > /root/.oci/config
          - echo "user=${oci_identity_user.ocir_user.id}" >> /root/.oci/config
          - echo "fingerprint=${oci_identity_api_key.ocir_user_api_key.fingerprint}" >> /root/.oci/config
          - echo "tenancy=${var.tenancy_id}" >> /root/.oci/config
          - echo "region=${var.region}" >> /root/.oci/config
          - echo "key_file=/root/.oci/api.key" >> /root/.oci/config
          - chmod 600 /root/.oci/config
          - 'curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh'
          - 'wget https://github.com/oracle-devrel/oke-credential-provider-for-ocir/releases/latest/download/oke-credential-provider-for-ocir-linux-amd64 -O /usr/local/bin/credential-provider-oke'
          - 'wget https://github.com/oracle-devrel/oke-credential-provider-for-ocir/releases/latest/download/credential-provider-config.yaml -P /etc/kubernetes/'
          - sed -i 's/INSTANCE_PRINCIPAL/USER_PRINCIPAL/g' /etc/kubernetes/credential-provider-config.yaml
          - 'sudo chmod 755 /usr/local/bin/credential-provider-oke'
          - 'bash -x /var/run/oke-init.sh --kubelet-extra-args "--image-credential-provider-bin-dir=/usr/local/bin/ --image-credential-provider-config=/etc/kubernetes/credential-provider-config.yaml"'
          - 'touch /var/log/oke.done'          
          EOT
          content_type = "text/cloud-config",
          filename     = "10-taints.yml"
        }

      ],
    }
  }

  default_obs_worker_pools = {
    observation = {
      create           = true
      mode             = "node-pool",
      size             = 2,
      shape            = "VM.Standard.E4.Flex",
      ocpus            = 1,
      memory           = 16,
      boot_volume_size = 50,
      node_labels = {
        "project"                       = "observation",
        "oke.oraclecloud.com/pool.name" = "observation"
      },
      disable_default_cloud_init = true,
      cloud_init = [
        {
          content      = jsonencode({ timezone = "Etc/UTC" })
          content_type = "text/cloud-config",
          filename     = "10-timezone.yml"
        },
        {
          content = jsonencode({
            # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#growpart
            growpart = {
              mode                     = "auto"
              devices                  = ["/"]
              ignore_growroot_disabled = false
            }

            # https://cloudinit.readthedocs.io/en/latest/reference/modules.html#resizefs
            resize_rootfs = true

            # Resize logical LVM root volume when utility is present
            bootcmd = ["if [[ -f /usr/libexec/oci-growfs ]]; then /usr/libexec/oci-growfs -y; fi"]
          })
          content_type = "text/cloud-config",
          filename     = "10-growpart.yml"
        },
        {
          content = jsonencode({
            write_files = [
              {
                content = module.oke_cluster.apiserver_private_host
                path    = "/etc/oke/oke-apiserver"
              },
              {
                content  = module.oke_cluster.cluster_ca_cert
                encoding = "base64"
                path     = "/etc/kubernetes/ca.crt"
              },
            ]
          })
          content_type = "text/cloud-config",
          filename     = "50-oke-config.yml"
          merge_type   = "list(append)+dict(no_replace,recurse_list)+str(append)"
        },
        {
          content      = <<-EOT
          runcmd:
          - mkdir -p /root/.oci/
          - echo ${base64encode(nonsensitive(tls_private_key.oci_api_key.private_key_pem))} | base64 -d > /root/.oci/api.key
          - chmod 600 /root/.oci/api.key
          - echo "[DEFAULT]" > /root/.oci/config
          - echo "user=${oci_identity_user.ocir_user.id}" >> /root/.oci/config
          - echo "fingerprint=${oci_identity_api_key.ocir_user_api_key.fingerprint}" >> /root/.oci/config
          - echo "tenancy=${var.tenancy_id}" >> /root/.oci/config
          - echo "region=${var.region}" >> /root/.oci/config
          - echo "key_file=/root/.oci/api.key" >> /root/.oci/config
          - chmod 600 /root/.oci/config
          - 'curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh'
          - 'wget https://github.com/oracle-devrel/oke-credential-provider-for-ocir/releases/latest/download/oke-credential-provider-for-ocir-linux-amd64 -O /usr/local/bin/credential-provider-oke'
          - 'wget https://github.com/oracle-devrel/oke-credential-provider-for-ocir/releases/latest/download/credential-provider-config.yaml -P /etc/kubernetes/'
          - sed -i 's/INSTANCE_PRINCIPAL/USER_PRINCIPAL/g' /etc/kubernetes/credential-provider-config.yaml
          - 'sudo chmod 755 /usr/local/bin/credential-provider-oke'
          - 'bash -x /var/run/oke-init.sh --kubelet-extra-args "--image-credential-provider-bin-dir=/usr/local/bin/ --image-credential-provider-config=/etc/kubernetes/credential-provider-config.yaml"'
          - 'touch /var/log/oke.done'          
          EOT
          content_type = "text/cloud-config",
          filename     = "10-taints.yml"
        }

      ],
    }
  }

}

locals {
  oke_compartment_id            = lookup(var.k8s_cluster_properties, "compartment_id", var.compartment_id)
  oke_home_region               = lookup(var.k8s_cluster_properties, "home_region", local.home_region)
  oke_region                    = lookup(var.k8s_cluster_properties, "region", var.region)
  oke_cluster_name              = lookup(var.k8s_cluster_properties, "cluster_name", "mosip${var.env}")
  oke_cni_type                  = lookup(var.k8s_cluster_properties, "cni", "flannel")
  oke_vcn_cidr                  = lookup(var.k8s_cluster_properties, "vcn_cidr", ["10.0.0.0/16"])
  oke_cluster_type              = lookup(var.k8s_cluster_properties, "cluster_type", "enhanced")
  oke_control_plane_access      = lookup(var.k8s_cluster_properties, "control_plane_is_public", false)
  oke_kubernetes_version        = lookup(var.k8s_cluster_properties, "kubernetes_version", local.k8s_latest_version)
  oke_bastion_image_id          = lookup(var.k8s_cluster_properties, "bastion_image_id", local.bastion_image_id)
  oke_operator_image_id         = lookup(var.k8s_cluster_properties, "operator_image_id", local.operator_image_id)
  oke_bastion_allowed_cidrs     = lookup(var.k8s_cluster_properties, "bastion_allowed_cidrs", var.bastion_allowed_cidrs)
  oke_k8s_allow_rules_public_lb = lookup(var.k8s_cluster_properties, "k8s_allow_rules_public_lb", var.k8s_allow_rules_public_lb)
  oke_k8s_allow_rules_int_lb    = lookup(var.k8s_cluster_properties, "k8s_allow_rules_int_lb", var.k8s_allow_rules_int_lb)
  oke_tags                      = lookup(var.k8s_cluster_properties, "tags", var.tags)
  oke_ssh_private_key           = lookup(var.k8s_cluster_properties, "ssh_private_key", var.ssh_private_key)
  oke_ssh_public_key            = lookup(var.k8s_cluster_properties, "ssh_public_key", var.ssh_public_key)
  oke_allow_worker_ssh_access   = lookup(var.k8s_cluster_properties, "allow_worker_ssh_access", true)
  oke_operator_install_k9s      = lookup(var.k8s_cluster_properties, "operator_install_k9s", true)
  oke_cluster_addons            = lookup(var.k8s_cluster_properties, "cluster_addons", var.cluster_addons)
  oke_cluster_drg_id            = lookup(var.k8s_cluster_properties, "drg_id", var.drg_id)
  oke_cluster_igw_route_rules   = lookup(var.k8s_cluster_properties, "igw_rt_rules", var.internet_gateway_route_rules)
  oke_cluster_nat_route_rules   = lookup(var.k8s_cluster_properties, "nat_rt_rules", var.nat_gateway_route_rules)
  oke_cluster_cp_allowed_cidrs  = lookup(var.k8s_cluster_properties, "cp_allowed_cidrs", local.cp_allowed_cidrs)
  oke_worker_pools = lookup(
    var.k8s_cluster_properties,
    "worker_pools", local.default_worker_pools
  )
  oke_subnets = {
    "bastion" = {
      "create" = "never"
      "id"     = local.public_subnet_id
      "cidr"   = local.public_subnet_cidr
    },
    "pub_lb" = {
      "create" = "never"
      "id"     = local.public_subnet_id
      "cidr"   = local.public_subnet_cidr
    },
    "cp" = {
      "create" = "never"
      "id"     = local.oke_cp_subnet_id
      "cidr"   = local.oke_cp_subnet_cidr
    },
    "int_lb" = {
      "create" = "never"
      "id"     = local.public_subnet_id
      "cidr"   = local.public_subnet_cidr
    },
    "operator" = {
      "create" = "never"
      "id"     = local.private_subnet_id
      "cidr"   = local.private_subnet_cidr
    },
    "pods" = {
      "create" = "never"
      "id"     = local.private_subnet_id
      "cidr"   = local.private_subnet_cidr
    },
    "workers" = {
      "create" = "never"
      "id"     = local.private_subnet_id
      "cidr"   = local.private_subnet_cidr
    }
  }
}



locals {
  obs_oke_compartment_id            = lookup(var.obs_k8s_cluster_properties, "compartment_id", var.compartment_id)
  obs_oke_home_region               = lookup(var.obs_k8s_cluster_properties, "home_region", local.home_region)
  obs_oke_region                    = lookup(var.obs_k8s_cluster_properties, "region", var.region)
  obs_oke_cluster_name              = lookup(var.obs_k8s_cluster_properties, "cluster_name", "mosipobs")
  obs_oke_cni_type                  = lookup(var.obs_k8s_cluster_properties, "cni", "flannel")
  obs_oke_cluster_type              = lookup(var.obs_k8s_cluster_properties, "cluster_type", "enhanced")
  obs_oke_control_plane_access      = lookup(var.obs_k8s_cluster_properties, "control_plane_is_public", false)
  obs_oke_kubernetes_version        = lookup(var.obs_k8s_cluster_properties, "kubernetes_version", local.k8s_latest_version)
  obs_oke_bastion_image_id          = lookup(var.obs_k8s_cluster_properties, "bastion_image_id", local.bastion_image_id)
  obs_oke_operator_image_id         = lookup(var.obs_k8s_cluster_properties, "operator_image_id", local.operator_image_id)
  obs_oke_bastion_allowed_cidrs     = lookup(var.obs_k8s_cluster_properties, "bastion_allowed_cidrs", var.bastion_allowed_cidrs)
  obs_oke_k8s_allow_rules_public_lb = lookup(var.obs_k8s_cluster_properties, "k8s_allow_rules_public_lb", var.obs_k8s_allow_rules_public_lb)
  obs_oke_k8s_allow_rules_int_lb    = lookup(var.obs_k8s_cluster_properties, "k8s_allow_rules_int_lb", var.obs_k8s_allow_rules_int_lb)
  obs_oke_tags                      = lookup(var.obs_k8s_cluster_properties, "tags", var.tags)
  obs_oke_ssh_private_key           = lookup(var.obs_k8s_cluster_properties, "ssh_private_key", var.ssh_private_key)
  obs_oke_ssh_public_key            = lookup(var.obs_k8s_cluster_properties, "ssh_public_key", var.ssh_public_key)
  obs_oke_allow_worker_ssh_access   = lookup(var.obs_k8s_cluster_properties, "allow_worker_ssh_access", true)
  obs_oke_operator_install_k9s      = lookup(var.obs_k8s_cluster_properties, "operator_install_k9s", true)
  obs_oke_cluster_addons            = lookup(var.obs_k8s_cluster_properties, "cluster_addons", var.cluster_addons)
  obs_oke_cluster_drg_id            = lookup(var.obs_k8s_cluster_properties, "drg_id", var.drg_id)
  obs_oke_cluster_igw_route_rules   = lookup(var.obs_k8s_cluster_properties, "igw_rt_rules", var.internet_gateway_route_rules)
  obs_oke_cluster_nat_route_rules   = lookup(var.obs_k8s_cluster_properties, "nat_rt_rules", var.nat_gateway_route_rules)
  obs_oke_cluster_cp_allowed_cidrs  = lookup(var.obs_k8s_cluster_properties, "cp_allowed_cidrs", local.cp_allowed_cidrs)
  obs_oke_subnets = {
    "bastion" = {
      "create" = "never"
      "id"     = local.public_subnet_id
      "cidr"   = local.public_subnet_cidr
    },
    "pub_lb" = {
      "create" = "never"
      "id"     = local.public_subnet_id
      "cidr"   = local.public_subnet_cidr
    },
    "cp" = {
      "create" = "never"
      "id"     = local.oke_cp_subnet_id
      "cidr"   = local.oke_cp_subnet_cidr
    },
    "int_lb" = {
      "create" = "never"
      "id"     = local.public_subnet_id
      "cidr"   = local.public_subnet_cidr
    },
    "operator" = {
      "create" = "never"
      "id"     = local.private_subnet_id
      "cidr"   = local.private_subnet_cidr
    },
    "pods" = {
      "create" = "never"
      "id"     = local.private_subnet_id
      "cidr"   = local.private_subnet_cidr
    },
    "workers" = {
      "create" = "never"
      "id"     = local.private_subnet_id
      "cidr"   = local.private_subnet_cidr
    }
  }
  obs_oke_worker_pools = lookup(
    var.obs_k8s_cluster_properties,
    "worker_pools", local.default_obs_worker_pools
  )

}


locals {
  mosip_policy = concat(
    local.mosip_policy_statements
  )

  mosip_policy_statements = [
    "Allow dynamic-group oke-workers-${local.oke_cluster_name} to manage all-resources in compartment id ${var.compartment_id}",
  ]
}


locals {
  ocir_policy_statements = concat(
    local.oci_ocir_statements
  )

  oci_ocir_statements = [
    "Allow group ${oci_identity_group.ocir_group.name} to manage repos in compartment id ${var.compartment_id}",
  ]
}