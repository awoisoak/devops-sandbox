output "web_public_ip" {
  description = "The public IP of the web server"
  value       = aws_eip.web_server_ip.public_ip
  depends_on  = [aws_eip.web_server_ip]
}

output "web_public_dns" {
  description = "The public DNS of the web server"
  value       = aws_eip.web_server_ip.public_ip
  depends_on  = [aws_eip.web_server_ip]
}

output "database_address" {
  description = "The endpoint of the database"
  value       = aws_db_instance.database.address
}

output "database_port" {
  description = "The port of the database"
  value       = aws_db_instance.database.port
}