terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("gcp-tf-sa.json")

  project = "datacloud-lab"
  region  = "us-central1"
  zone    = "us-central1-c"
}

provider "google-beta" {
  credentials = file("gcp-tf-sa.json")

  project = "datacloud-lab"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "datacloud_lab_vpc_network_1" {
  name                    = "datacloud-lab-vpc-1"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "network_with_private_subnet_1" {
  name                     = "datacloud-lab-subnet-us-central1"
  ip_cidr_range            = "10.128.0.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.datacloud_lab_vpc_network_1.id
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "network_with_private_subnet_2" {
  name                     = "datacloud-lab-subnet-asia-east1"
  ip_cidr_range            = "10.128.1.0/24"
  region                   = "asia-east1"
  network                  = google_compute_network.datacloud_lab_vpc_network_1.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "tcp_80_allow_rule" {
  name    = "datacloud-lab-internet-subnet-tcp-80-allow-rule"
  network = google_compute_network.datacloud_lab_vpc_network_1.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.128.0.0/24", "10.128.1.0/24"]
  direction     = "INGRESS"
  priority      = 1000
}

resource "google_compute_firewall" "tcp_443_allow_rule" {
  name    = "datacloud-lab-internet-subnet-tcp-443-allow-rule"
  network = google_compute_network.datacloud_lab_vpc_network_1.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["10.128.0.0/24", "10.128.1.0/24"]
  direction     = "INGRESS"
  priority      = 1000
}

resource "google_compute_firewall" "tcp_22_allow_rule" {
  name    = "datacloud-lab-internet-subnet-tcp-22-allow-rule"
  network = google_compute_network.datacloud_lab_vpc_network_1.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.128.0.0/24", "10.128.1.0/24"]
  direction     = "INGRESS"
  priority      = 65534
}

resource "google_compute_firewall" "icmp_allow_rule" {
  name    = "datacloud-lab-internet-subnet-icmp-allow-rule"
  network = google_compute_network.datacloud_lab_vpc_network_1.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.128.0.0/24", "10.128.1.0/24"]
  direction     = "INGRESS"
  priority      = 65534
}

resource "google_compute_firewall" "allow_internal" {
  name    = "datacloud-lab-internet-subnet-allow-internal"
  network = google_compute_network.datacloud_lab_vpc_network_1.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.128.0.0/24", "10.128.1.0/24"]
  direction     = "INGRESS"
  priority      = 65534
}
