output "cloud_run_url" {
  description = "URL of the API deployed in Cloud Run"
  value       = google_cloud_run_service.api_service.status[0].url
}

===============
FILE: schema/migrations.sql
===============
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT
);

INSERT INTO users (first_name, last_name, phone, email, address)
VALUES
('John', 'Doe', '1234567890', 'john.doe@example.com', '123 Main St'),
('Jane', 'Smith', '9876543210', 'jane.smith@example.com', '456 Another Rd'),
('Bob', 'Johnson', '4567891230', 'bob.johnson@example.com', '789 Some Pl');
