
output "ec2_public_ip" {
  description = "IP aws_eip address ec2_instance"
  value       = module.vpn-main.ec2_public_ip
}

output "password_mysql" {
  description = "Random password to mysql"
  value       = resource.random_password.mysql_root_password.result
  sensitive = true
}

output "password_openvpn" {
  description = "Random password to mysql"
  value       = resource.random_password.openvpn_admin_password.result
  sensitive = true
}