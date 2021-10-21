# Input variable definitions
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "name_ec2" {
  description = "Name of EC2 instance"
  type        = string
  default     = "main-vpn-instance"

}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "TWS-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24"]
}

variable "user_data" {
  description = "user-data master and slave"
  type        = string
  default     = "data.template_file.master.rendered"
}

variable "master_ip" {
  description = "Ip master instance"
  type        = string
  default     = "127.0.0.1"
}

variable "create_key_pair" {
  description = "Creite kay pair"
  type        = bool
  default     = true
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "ami_owners" {
  description = "The owners of ami images for search"
  type        = list(any)
  default     = ["099720109477"] # Canonical
  # 137112412989 - Amazon
}

variable "ami_search_strings" {
  description = "he array of search strings as part name of image"
  type        = list(any)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210511"] # Canonical ubuntu 20.04
  # default     = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*"] # Canonical ubuntu 20.04
  # amzn2-ami-hvm-2.0.*-x86_64-gp2 - Amazon linux
}

variable "ami_arch" {
  description = "The architecture for image"
  type        = list(any)
  default     = ["x86_64"]
}