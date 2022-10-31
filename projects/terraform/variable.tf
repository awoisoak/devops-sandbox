variable "region" {
  default = "ap-northeast-1"
}
variable "db_username" {
  sensitive = true
}
variable "db_password" {
  sensitive = true
}
variable "my_ip" {
  sensitive = true
}