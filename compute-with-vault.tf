# Set up provider for Vault
provider "vault" {
  # Vault address is typically the default; replace with your Vault address if different
  address = "http://127.0.0.1:8200"  # Vault address
}

# Set up provider for GCP
provider "google" {
  credentials = data.vault_generic_secret.gcp_credentials.data["credentials"]  # Fetch GCP credentials from Vault
  project     = "<YOUR-GCP-PROJECT>"   # Replace with your GCP project ID
  region      = "us-central1"           # GCP region
}

# Fetch GCP credentials from Vault
data "vault_generic_secret" "gcp_credentials" {
  path = "secret/gcp-credentials"  # Path where GCP credentials are stored in Vault
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

# Create a subnetwork for the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.0.0/24"
}

# Create a Linux VM instance
resource "google_compute_instance" "linux_vm" {
  name         = "my-linux-vm"
  machine_type = "e2-medium"   # Change machine type as needed
  zone         = "us-central1-a"  # GCP zone for your instance

  # Network configuration
  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {}  # Assign a public IP to the instance
  }

  # Boot disk configuration
  boot_disk {
    initialize_params {
      image = "debian-11-bullseye-v20231115"  # OS image for your instance
    }
  }

  # SSH key metadata for logging into the instance
  metadata = {
    ssh-keys = "your-username:${file("~/.ssh/id_rsa.pub")}"
  }
}

# Create a firewall rule to allow SSH access to the VM
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow SSH from anywhere
}
