provider "aws" {
    region = "us-east-1"
#    profile = "terraform"
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
    username = var.db_username 
    password = var.db_password 
}