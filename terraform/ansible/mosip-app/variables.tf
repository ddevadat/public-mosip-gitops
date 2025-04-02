variable "ansible_collection_url" {
  default = "git+https://github.com/oci-mosip/public-mosip-gitops.git#/ansible/generic/iac"
}

variable "ansible_collection_tag" {
  default = "mosip-document"
}


variable "ansible_bastion_public_ip" {
  description = "ip for bastion host"
}

variable "ansible_bastion_os_username" {
  default     = "opc"
  description = "username for bastion host"
}

variable "ansible_base_output_dir" {
  description = "where to read/write ansible inv/etc"
  default     = "/tmp/mosip/output"
}

variable "env" {
  description = "env name"
  default     = "dev"
}

variable "operator_hosts_maps" {
  type        = map(any)
  description = "map of hosts to run operator"
}

variable "operator_hosts_var_maps" {
  type        = map(any)
  description = "var map for operator hosts"
}


variable "ssh_private_key" {
  default     = ""
  type        = string
  description = "ssh private key in base64 format"
}