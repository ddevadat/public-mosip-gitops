

variable "tenancy_id" {
  description = "The tenancy id of the OCI Cloud Account in which to create the resources."
  type        = string
}

variable "region" {
  type        = string
  description = "The OCI region"
}

variable "user_ocid" {
  type        = string
  description = "The user ocid"
}

variable "private_key" {
  type        = string
  description = "The api private key"
}

variable "fingerprint" {
  type        = string
  description = "The api fingerprint"
}

variable "home_region" {
  type        = string
  description = "The OCI home region"
}

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "operator_availability_domain" {
  default = null
  type    = string
}

variable "vcn_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR Subnet to use for the VCN, will be split into multiple /24s for the required private and public subnets"
}


variable "vcn_properties" {
  default = {
    vcn_name = "mosipdoc"
    vcn_cidr = ["10.0.0.0/16"]
    subnet_maps = {
      "public_sub1" = {
        name       = "public-subnet"
        cidr_block = "10.0.0.16/28"
        type       = "public"
        dns_label  = "public"
      }
      "private_sub1" = {
        name       = "private-subnet"
        cidr_block = "10.0.32.0/19"
        type       = "private"
        dns_label  = "private"
      }
      "private_sub2" = {
        name       = "oke-control-plane"
        cidr_block = "10.0.0.0/28"
        type       = "private"
        dns_label  = "okectrp"
      }
    }
  }
  description = "Default vcn properties"
  type        = any
}


variable "tags" {
  description = "Contains default tags for this project"
  type        = map(string)
  default     = {}
}


variable "bastion_shape" {
  default     = "VM.Standard.E3.Flex"
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance."
}

variable "operator_shape" {
  default     = "VM.Standard.E3.Flex"
  description = "A shape is a template that determines the number of OCPUs, amount of memory, and other resources allocated to a newly created instance."
}

variable "bastion_os" {
  default     = "Oracle Linux"
  description = "The OS/image for bastion."
}
variable "bastion_os_version" {
  default     = "8"
  description = "The OS/image version for bastion."
}

variable "operator_os" {
  default     = "Oracle Linux"
  description = "The OS/image for operator."
}
variable "operator_os_version" {
  default     = "8"
  description = "The OS/image version for operator."
}


variable "k8s_cluster_properties" {
  default = {
    cni                     = "flannel"
    cluster_type            = "enhanced"
    vcn_cidr                = ["10.0.0.0/16"]
    bastion_allowed_cidrs   = ["0.0.0.0/0"]
    control_plane_is_public = false
    worker_pools = {
      workload = {
        create           = true
        mode             = "node-pool",
        size             = 1,
        shape            = "VM.Standard.E4.Flex",
        ocpus            = 1,
        memory           = 16,
        boot_volume_size = 50,
        node_labels = {
          "project"                       = "workload",
          "oke.oraclecloud.com/pool.name" = "workload"
        }
      }
    }
  }
  description = "Default oke properties"
  type        = any
}


variable "obs_k8s_cluster_properties" {
  default = {
    cni                     = "flannel"
    cluster_type            = "enhanced"
    bastion_allowed_cidrs   = ["0.0.0.0/0"]
    control_plane_is_public = false
    worker_pools = {
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
        }
      }
    }
  }
  description = "Default observation oke properties"
  type        = any
}

variable "k8s_allow_rules_public_lb" {
  default = {
    "Allow TCP ingress to public load balancers for https traffic from client" = {
      protocol    = 6
      port        = 443
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
    },
    "Allow TCP ingress to public load balancers for http traffic from client" = {
      protocol    = 6
      port        = 80
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
    }
  }
  description = "Default rules for public load balancers"
  type        = any
}

variable "k8s_allow_rules_int_lb" {
  default = {
    "Allow TCP ingress to public load balancers for postgres traffic from client" = {
      protocol    = 6
      port        = 5432
      source      = "10.0.0.0/16"
      source_type = "CIDR_BLOCK"
    },
    "Allow TCP ingress to public load balancers for redis traffic from client" = {
      protocol    = 6
      port        = 6379
      source      = "10.0.0.0/16"
      source_type = "CIDR_BLOCK"
    },
    "Allow TCP ingress to public load balancers for https new traffic from client" = {
      protocol    = 6
      port        = 443
      source      = "10.0.0.0/16"
      source_type = "CIDR_BLOCK"
    },
    "Allow TCP ingress to public load balancers for http new traffic from client" = {
      protocol    = 6
      port        = 80
      source      = "10.0.0.0/16"
      source_type = "CIDR_BLOCK"
    },
  }
  description = "Default rules for private load balancers"
  type        = any
}


variable "obs_k8s_allow_rules_public_lb" {
  default = {
    "Allow TCP ingress to public load balancers for https traffic from client" = {
      protocol    = 6
      port        = 443
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
    },
    "Allow TCP ingress to public load balancers for http traffic from client" = {
      protocol    = 6
      port        = 80
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
    }
  }
  description = "Default rules for public load balancers"
  type        = any
}

variable "obs_k8s_allow_rules_int_lb" {
  default = {
    "Allow TCP ingress to public load balancers for https traffic from client" = {
      protocol    = 6
      port        = 443
      source      = "10.0.0.0/16"
      source_type = "CIDR_BLOCK"
    },
    "Allow TCP ingress to public load balancers for http traffic from client" = {
      protocol    = 6
      port        = 80
      source      = "10.0.0.0/16"
      source_type = "CIDR_BLOCK"
    },

  }
  description = "Default rules for private load balancers"
  type        = any
}

variable "ssh_public_key" {
  default     = ""
  type        = string
  description = "ssh public key"
}

variable "ssh_private_key" {
  default     = ""
  type        = string
  description = "ssh private key in bas64 format"
}

variable "bastion_allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


variable "cluster_addons" {
  description = "Map with cluster addons. This operation is performed using oci-cli and requires the operator host to be deployed."
  type        = any
  default     = {}
}

variable "domain" {
  description = "Domain to attach the cluster to."
  type        = string
  default     = ""
}


variable "vault_id" {
  type        = string
  description = "vault ocid"
}

variable "vault_enc_key_id" {
  type        = string
  description = "vault master encryption key id"
}

variable "keycloak_client_secrets" {
  type    = list(string)
  default = []
}

variable "certificate_email" {
  type        = string
  description = "email id for ssl certification renewal notice"
  default     = "dummy@xyz.com"
}


variable "ssl_cert_type" {
  type        = string
  default     = "stage"
  description = "LetsEncrypt SSL certificate type"
  validation {
    condition     = var.ssl_cert_type == "stage" || var.ssl_cert_type == "prod"
    error_message = "The ssl_cert_type variable must be either 'stage' or 'prod'."
  }
}

variable "application_repo" {
  type        = string
  description = "The github repo of application code"
  default     = "https://github.com/oci-mosip/public-mosip-gitops"
}


variable "ocir_user_email" {
  type        = string
  description = "email id for ocir user"
  default     = "dummy@xyz.com"
}

variable "drg_id" {
  default     = null
  description = "ID of an external created Dynamic Routing Gateway to be attached to the VCN."
  type        = string
}

variable "vpn_server" {
  default     = "10.0.0.5/32"
  type        = string
  description = "VPN Server IP"
}

variable "internet_gateway_route_rules" {
  default     = null
  description = "(Updatable) List of routing rules to add to Internet Gateway Route Table."
  type        = list(map(string))
}

variable "nat_gateway_route_rules" {
  default     = null
  description = "(Updatable) List of routing rules to add to Internet Gateway Route Table."
  type        = list(map(string))
}

variable "env" {
  description = "env name"
  default     = "dev"
}

variable "flannel_pods_cidr" {
  type        = string
  default     = "10.244.0.0/16"
  description = "Pods CIDR for Flannel"
}

variable "operator_user" {
  default     = "opc"
  description = "User for SSH access to operator host."
  type        = string
}


variable "workload_name" {
  default     = "MOSIP"
  type        = string
}