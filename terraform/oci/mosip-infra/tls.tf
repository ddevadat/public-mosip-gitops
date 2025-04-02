resource "tls_private_key" "oci_api_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
