variable "name" {}
variable "cidr_block" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "ec2_ami" { default = "ami-07860a2d7eb515d9a" }
variable "ec2_type" { default = "t3.micro" }
