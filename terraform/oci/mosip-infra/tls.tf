resource "tls_private_key" "oci_api_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
