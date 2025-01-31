variable "project_id" {
  type        = string
  description = "Project ID of GCP"
}

variable "region" {
  type        = string
  description = "Deployment Region"
  default     = "us-central1"
}

variable "db_username" {
  type        = string
  description = "username PostgreSQL"
  default     = "postgres_user"
}

variable "db_password" {
  type        = string
  description = "password PostgreSQL"
  sensitive   = true
}

variable "api_image_url" {
  type        = string
  description = "URL  Docker image for Cloud Run "
}