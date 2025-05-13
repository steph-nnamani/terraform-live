provider "aws" {
    region = "us-east-1"
#    profile = "terraform"
}

# You can use aws_secretsmanager_secret_version data source to 
# read the db-creds secret from AWS Secret Manager.

data "aws_secretsmanager_secret_version" "creds" {
    secret_id = "db-creds"
}

# Since the secrets is stored in JSON, you can use the jsondecode function 
# to parse the JSON into the local variable db_creds:
locals {
    db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

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
}