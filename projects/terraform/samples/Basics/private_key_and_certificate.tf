resource "local_file" "key_data" {
  filename        = "/tmp/.pki/private_key.pem"
  content         = tls_private_key.private_key.private_key_pem
  file_permission = "0400"
}
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "tls_cert_request" "csr" {

  private_key_pem = file("/tmp/.pki/private_key.pem")
  depends_on      = [local_file.key_data]

  subject {
    common_name  = "flexit.com"
    organization = "FlexIT Consulting Services"
  }
}