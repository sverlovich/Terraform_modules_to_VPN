# Output variable definitions

output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "vpc_id" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.vpc_id
}

output "ec2_id" {
  description = "IDs ec2_instance"
  value       = module.ec2-instance.id
}

output "ec2_arn" {
  description = "ARN ec2_instance"
  value       = module.ec2-instance.arn
}

output "ec2_public_ip" {
  description = "IP aws_eip address ec2_instance"
  value       = resource.aws_eip.public_ip.public_ip 
}
