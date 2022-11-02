variable "region" {
  default = "ap-northeast-1"
}
variable "db_username" {
  sensitive = true
}
variable "db_password" {
  sensitive = true
}
variable "public_key_path" {
  default = "/Users/awo/.ssh/aws_id_rsa.pub"
}