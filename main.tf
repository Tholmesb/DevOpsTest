terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------
# 1. VPC and Private Subnet
# -------------------------
resource "google_compute_network" "vpc" {
  name                    = "devops-test-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "devops-test-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.self_link
  region        = var.region
  private_ip_google_access = true
}

# -------------------------
# 2. NAT Gateway
# -------------------------
resource "google_compute_router" "nat_router" {
  name    = "devops-test-nat-router"
  network = google_compute_network.vpc.self_link
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                               = "devops-test-nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# -------------------------
# 3. Cloud SQL: PostgreSQL
# -------------------------
resource "google_sql_database_instance" "postgres_instance" {
  name             = "devops-postgres-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
    }
  }
}

resource "google_sql_database" "users_db" {
  name     = "users_db"
  instance = google_sql_database_instance.postgres_instance.name
  project  = var.project_id
}

resource "google_sql_user" "postgres_user" {
  name     = var.db_username
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

# -------------------------
# 4. Serverless VPC Connector
# -------------------------
resource "google_vpc_access_connector" "serverless_connector" {
  name          = "serverless-vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
}

# -------------------------
# 5. Cloud Run Service
# -------------------------
resource "google_cloud_run_service" "api_service" {
  name     = "users-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.api_image_url

        env = [
          {
            name  = "DB_HOST"
            value = google_sql_database_instance.postgres_instance.connection_name
          },
          {
            name  = "DB_NAME"
            value = google_sql_database.users_db.name
          },
          {
            name  = "DB_USER"
            value = var.db_username
          },
          {
            name  = "DB_PASS"
            value = var.db_password
          },
        ]
      }
      container_concurrency = 80

      vpc_access {
        connector = google_vpc_access_connector.serverless_connector.name
        egress    = "PRIVATE_RANGES_ONLY"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "api_invoker" {
  location = var.region
  service  = google_cloud_run_service.api_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}