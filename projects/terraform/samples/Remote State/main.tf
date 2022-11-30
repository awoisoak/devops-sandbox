resource "local_file" "state" {
  filename = "/root/${var.remote-state}"
  content = "This configuration uses ${var.remote-state} state"
}