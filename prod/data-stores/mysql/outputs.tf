# output "address" {
#   value = aws_db_instance.example.address
#   description = "Connect to the database at this endpoint"
# }

# output "port" {
#   value = aws_db_instance.example.port
#   description = "The port the database is listening on"
# }

output "primary_address" {
  value       = module.mysql_primary.address
  description = "Connect to the primary database at this endpoint"
}
output "replica_address" {
  value       = module.mysql_replica.address
  description = "Connect to the replica database at this endpoint"
}

output "primary_port" {
  value       = module.mysql_primary.port
  description = "The primary database port"
}

output "replica_port" {
  value       = module.mysql_replica.port
  description = "The replica database port"
}

output "primary_arn" {
    value       = module.mysql_primary.arn
    description = "The primary database arn"
}

output "replica_arn" {
    value       = module.mysql_replica.arn
    description = "The replica database arn"
}