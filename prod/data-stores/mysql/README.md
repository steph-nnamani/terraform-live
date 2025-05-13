# Pass the database credentials as environmental variables
export TF_VAR_db_username="admin"
export TF_VAR_db_password="myadminpass"

- If you do not set this environmental variable on the bash terminal, you will be prompted interactively for the db_username and db_password when you run terraform apply or terraform plan.


# You can manage secrets using:
1. Environmental variables
2. Encrypted files
3. Secret stores (aws secret manager, google secret manager, azure vault)

For our database credentials: 
    We will store it in aws secrets manager. See pages 214-217.

# Steps:
1. Store the secrets in JSON format in AWS Secret MANAGER
2. Give the Secrets a unique name (db-creds) in AWS Secret Manager.
3. Click NEXT and Save the Secret

4. Go back to your Terraform code;
5. Use aws_secretsmanager_secret_version data source to read the db-creds secret.

data "aws_secretsmanager_secret_version" "creds" {
    secret_id = "db-creds"
}

# Since the secrets is stored in JSON, you can use the jsondecode function 
# to parse the JSON into the local variable db_creds:
locals {
    db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

# Now you can read the database credentials from db-creds and pass them 
# into the aws_db_instance resource.

resource "aws_db_instance" "example" {
    identifier_prefix = "${var.rds}-instance"
    engine = "mysql"
    engine_version = "8.0"
    allocated_storage = 10
    instance_class = var.instance_class
    skip_final_snapshot = true
    db_name = "${var.rds}_database"

    # disable backups to create DB faster
    backup_retention_period = 0

    # db attribute names
    username = local.db_creds.username 
    password = local.db_creds.password