terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Provider AWS
provider "aws" {
  region = "us-east-1"
}

module "vpc1" {
  source = "./modules/vpc"
  name   = "vpc1"
  cidr_block = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24","10.0.4.0/24"]
  azs = ["us-east-1a","us-east-1b"]
}