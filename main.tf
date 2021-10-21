provider "aws" {
  region = var.aws_region
}

resource "random_password" "mysql_root_password" {
  length           = 16
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 0

  keepers = {
    broker_name = "master-vpn-instance"
  }
}

resource "random_password" "openvpn_admin_password" {
  length           = 16
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 0

  keepers = {
    broker_name = "master-vpn-instance"
  }
}

resource "aws_iam_instance_profile" "vpn_profile" {
  name = "VPN-twsgo_profile"
  role = "VPN-twsgo"
}

module "vpn-main" {
  source = "./module"

  aws_region = "eu-west-2"
  name_ec2 = "master-vpn-instance"
  user_data = templatefile("module/userdata.sh.tpl",
    {
      MASTER_IP             = "NULL",
      MYSQL_PASSWORD        = resource.random_password.mysql_root_password.result,
      OPENVPN_PASSWORD      = resource.random_password.openvpn_admin_password.result,

  })
  
}

module "vpn-slave" {
  source = "./module"

  aws_region = "eu-central-1"
  name_ec2 = "slave-vpn-instance"
  user_data = templatefile("module/userdata.sh.tpl",
    {
      MASTER_IP             = module.vpn-main.ec2_public_ip,
      MYSQL_PASSWORD        = resource.random_password.mysql_root_password.result,
      OPENVPN_PASSWORD      = resource.random_password.openvpn_admin_password.result,
  })
  
}