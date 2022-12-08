###################################
# Network
###################################
# TODO should we use the subnetwork for the connection vs Service Producer VPC?
# ---------------------------------
# Public VPC
# ---------------------------------
resource "google_compute_network" "tokyo_vpc" {
  name                    = "tokyo-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "tokyo_public_subnet_1" {
  name          = "tokyo-public-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.tokyo_vpc.id
}

# ---------------------------------
# (Private) Service Producer VPC
# ---------------------------------
# Allocate a private range of IPs to be used by the services
# TODO this could be avoided and Google would implement it for us?
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.tokyo_vpc.id
}

# Private connection from our VPC network to the underlying service producer network.
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.tokyo_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# (Optional) Import or export custom routes
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.tokyo_vpc.name
  import_custom_routes = true
  export_custom_routes = true
}

## Uncomment this block after adding a valid DNS suffix
# resource "google_service_networking_peered_dns_domain" "default" {
#   name       = "example-com"
#   network    = google_compute_network.peering_network.name
#   dns_suffix = "example.com."
#   service    = "servicenetworking.googleapis.com"
# }

###################################
# Virtual Machines
###################################

resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = "e2-micro"
  zone         = var.zone
  # http-server is required as well even if not defined by the firewall rule.
  # Is the same that enable through the web interface the next checkbox VM Instance > Edit > Firewalls > Allow HTTP traffic
  tags = ["ssh", "http-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
      labels = {
        "my_label" = "my-value"
      }
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.tokyo_public_subnet_1.id
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
  # metadata_startup_script = file("scripts/setup_web_server.sh")
  # TODO find out how to grab the ip
  metadata_startup_script = templatefile("scripts/setup_web_server.sh", {
    "db_address" = "${google_sql_database_instance.database.private_ip_address}"
  })
}

resource "google_sql_database_instance" "database" {
  name             = "database"
  region           = var.region
  database_version = "MYSQL_8_0"

  depends_on = [
    google_service_networking_connection.default
  ]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.tokyo_vpc.id
    }
  }
  deletion_protection = false # set to true to prevent destruction of the resource
}

###################################
# Firewall
###################################

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  network       = google_compute_network.tokyo_vpc.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "photo_shop" {
  name    = "photo-shop"
  network = google_compute_network.tokyo_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}
