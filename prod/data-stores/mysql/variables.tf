variable "db_username" {
  type = string
  sensitive = true
  description = "Username for the database"
}
variable "db_password" {
  type = string
  sensitive = true
  description = "Password for the database"
}

variable "rds" {
  type = string
  description = "prefix name to distinguish of the RDS instance env"
  default = "prodawsrds"  # does not accept '-' hyphen
 }

variable "instance_class" {
  type = string
  description = "Instance class for the RDS instance"
  default = "db.t3.micro"
}
