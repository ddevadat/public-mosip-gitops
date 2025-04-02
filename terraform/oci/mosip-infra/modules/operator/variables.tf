# Copyright (c) 2019, 2023 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

# Common
variable "compartment_id" { type = string }
variable "state_id" {
   type = string 
   default = "mosipdoc"
   }

# Bastion (to await cloud-init completion)
# variable "bastion_host" { type = string }
# variable "bastion_user" { type = string }

# Operator
variable "await_cloudinit" { 
  type = bool
  default = true
  }
variable "assign_dns" { 
  type = bool 
  default = true
  }
variable "availability_domain" { type = string }
variable "cloud_init" { 
  type = list(map(string)) 
  default = []
  }
variable "image_id" { type = string }
variable "install_oci_cli_from_repo" { 
  type = bool 
  default = false
  }
variable "install_helm" {
  type    = bool
  default = true
}
variable "install_helm_from_repo" { 
  type = bool 
  default = true
  }
variable "install_istioctl" {
   type = bool
   default = false
}
variable "install_k9s" { 
  type = bool
  default = true
  
}
variable "install_kubectl_from_repo" { 
  type    = bool
  default = true
}
variable "install_kubectx" { 
  type = bool 
  default = true
}
# variable "kubeconfig" { type = string }
variable "kubernetes_version" { type = string }
variable "nsg_ids" { type = list(string) }
variable "operator_image_os_version" {
  default     = "8"
  description = "Operator image operating system version when operator_image_type = 'platform'."
  type        = string
}
variable "pv_transit_encryption" { 
  type = bool
  default = false
 }
variable "shape" {
  default = {
    shape            = "VM.Standard.E4.Flex",
    ocpus            = 1,
    memory           = 4,
    boot_volume_size = 50
  }
  description = "Shape of the created operator instance."
  type        = map(any)
}
variable "ssh_private_key" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" { type = string }
variable "subnet_id" { type = string }
variable "timezone" {
  default     = "Etc/UTC"
  description = "The preferred timezone for workers, operator, and bastion instances."
  type        = string
}
variable "upgrade" { 
  type = bool 
  default = true
  }
variable "user" { 
  type = string
  default= "opc"
}
variable "volume_kms_key_id" { 
  type = string 
  default = null
  }

# Tags
variable "freeform_tags" { type = map(string) }