# variable gcp_zone {}
# variable startup_script {}


# resource "google_compute_network" "vpc_network" {
#   name                    = "my-custom-mode-network"
#   auto_create_subnetworks = false
#   # mtu                     = 1460
# }

# resource "google_compute_subnetwork" "default" {
#   name                    = "my-custom-subnet"
#   ip_cidr_range = "10.0.1.0/24"
#   region        = var.gcp_zone
#   network       = google_compute_network.vpc_network.id
# }

# # Create a single Compute Engine instance
# resource "google_compute_instance" "default" {
#   name         = "flask-vm"
#   machine_type = "f1-micro"
#   zone         = var.gcp_zone
#   tags         = ["ssh"]

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   # Install Flask
#   metadata_startup_script = var.startup_script

#   network_interface {
#     subnetwork = google_compute_subnetwork.default.id

#     access_config {
#       # Include this section to give the VM an external IP address
#     }
#   }
# }
