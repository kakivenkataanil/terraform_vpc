output "az_names_local" {
  value = local.az_names
}

output "environment_local" {
  value = local.resource_name
}

output "elastic_ip" {
  value = aws_eip.nat.public_ip
}


output "aws_nat_gateway_id" {
  value = aws_nat_gateway.main.subnet_id
}