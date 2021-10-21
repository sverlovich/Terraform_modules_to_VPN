# Terraform configuration

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami_latest" {
  most_recent = true
  owners = var.ami_owners
  filter {
    name = "name"
    values = var.ami_search_strings
  }
  filter {
    name = "architecture"
    values = var.ami_arch
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]]
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  create_key_pair = var.create_key_pair

  key_name   = "tws-vpn-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE9Hr7gti3t68hmt1fpWZTXsFXDDaFTFtF7XbPe3YH2XRMpb2RUaMcDEv4H2UsUfeNZBmSBavemo+51gyUUegc+HsdP0+RP/gKbh5+ReBWM2aMTj6/VIj1tKxPH8zbD1zeVCxbmfttbmiKmqoRI/98kC3BY+CdmoK5nKxIQIQX5/qnqqHaBhDZz4Ok69DSFibU1AfI4vno3Cm4mMqGM09eRiBHJKbKeli+twm2XnXv/OpLLttvOhimhNgcW39AR+34tPGjF2yPC3+mmh64pjPUDUV0uX+ZhmOim5+MjUfu+4ZO729Ox3SdW1aOWzz0p1xPpnzwDvvO2cUFqPthm/m3 vpn_key"

}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "3.2.0"

  name = var.name_ec2
  
  ami                    = data.aws_ami.ami_latest.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [
    module.security_group_vpn.this_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = module.key_pair.key_pair_key_name
  user_data              = var.user_data
  iam_instance_profile   = "VPN-twsgo_profile"

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Project = "TWS-VPN"
  }
}

resource "aws_eip" "public_ip" {
  vpc = true
  instance = module.ec2-instance.id
}

module "security_group_vpn" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name = "tws-vpn"
  description = "Security group for EC2 instance with VPN"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = [
    "0.0.0.0/0"]
  ingress_rules = [
    "ssh-tcp"]

  ingress_with_cidr_blocks = [
     {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      description = "VPN-GUI-service ports (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },
     {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      description = "VPN-GUI-service ports (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },
     {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      description = "DB(ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 1194
      to_port = 1194
      protocol = "tcp"
      description = "VPN-service ports (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },

  ]
  egress_rules = [
    "all-all"]

  tags =  {
    Terraform   = "true"
    Environment = "dev"
    Name        = "tws-vpn"
  }
}