terraform {
  backend "s3" {
   bucket         = "github-actions-demo-terraform-tfstate"
   key            = "terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "aws-locks"
   encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source                      = "./modules/bootstrap"
  name_of_s3_bucket           = "github-actions-demo-terraform-tfstate"
  dynamo_db_table_name        = "aws-locks"
}

# Build the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"

  tags = {
    Name      = "Vpc"
    Terraform = "true"
  }
}

# Build route table 1
resource "aws_route_table" "route_table1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RouteTable1"
    Terraform = "true"
  }
}

# Build route table 2
resource "aws_route_table" "route_table2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RouteTable2"
    Terraform = "true"
  }
}
