output "web_public_ip" {
  description = "The public IP of the web server"
  value       = join("", ["http://", google_compute_instance.web_server.network_interface.0.access_config.0.nat_ip, ":80"])

}

output "db_private_ip" {
  description = "The private IP of the database"
  value       = google_sql_database_instance.database.private_ip_address
}
