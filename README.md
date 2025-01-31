# GCP DevOps Test

This README details how to deploy the infrastructure on GCP, perform the database schema migration, and use the API.

---

## 1. Infrastructure Deployment

1. **Prerequisites**:
   - [Terraform](https://www.terraform.io/downloads.html) >= 1.0
   - A Google Cloud service account with permissions to create and modify resources (roles `Editor` or `Owner`).
   - [gcloud CLI](https://cloud.google.com/sdk/docs/install) configured (optional, for building and pushing the API image).

2. **Project Configuration**:
   - Clone this repository:
     ```bash
     git clone https://github.com/<user>/<repo>.git
     cd <repo>
     ```
   - Go to the `terraform` directory and edit the variables in `variables.tf` or create a `terraform.tfvars` file:
     ```hcl
     project_id   = "YOUR_PROJECT_ID"
     region       = "us-central1"
     db_username  = "postgres_user"
     db_password  = "YOUR_DB_PASSWORD"
     api_image_url = "gcr.io/YOUR_PROJECT_ID/devops-api:latest"
     ```

3. **Deploy with Terraform**:
   - Initialize, plan, and apply:
     ```bash
     cd terraform
     terraform init
     terraform plan -var-file="terraform.tfvars"
     terraform apply -var-file="terraform.tfvars"
     ```
   - Once completed, you will see the Cloud Run URL in the output.

---

## 2. Schema Migration

1. **Script Location**  
   The `schema/migrations.sql` file contains the creation of the `users` table and the insertion of sample data.

2. **Running the Migration**
   - Connect to the PostgreSQL instance (using the private IP or the Cloud SQL Proxy).
   - Run the script directly:
     ```bash
     psql "host=<PRIVATE_DB_IP> user=postgres_user dbname=users_db password=YOUR_DB_PASSWORD" -f ./schema/migrations.sql
     ```
   - Verify that the `users` table was created and that the sample records are present.

---

## 3. API Usage

1. **Main Endpoint**  
   - The API provides a `GET /users` endpoint that returns a list of users in the table.

2. **Check the URL**  
   - After deployment, Terraform outputs the `cloud_run_url`.
   - Access it via your browser or a tool like `curl`:
     ```bash
     curl https://<CLOUD_RUN_URL>/users
     ```
   - You should receive a JSON list with the users inserted during the migration.

3. **Health Check Endpoint (Optional)**  
   - You can also use `GET /` to see a confirmation message that the API is running:
     ```bash
     curl https://<CLOUD_RUN_URL>/
     ```

---

## 4. Resource Cleanup

- To destroy all resources created by Terraform, run:
  ```bash
  terraform destroy -var-file="terraform.tfvars"
