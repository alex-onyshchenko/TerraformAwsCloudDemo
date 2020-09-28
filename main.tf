terraform {
  backend "s3" {
   bucket         = "github-actions-demo-terraform-tfstate"
   key            = "terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "aws-locks"
   encrypt        = true
  }
}

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

variable "ssh_key_private" {
  type = string
  default = "~/.ssh/awsdemo.pem"
}

resource "aws_instance" "web" {
  ami           = "ami-0bcc094591f354be2"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "awsdemo"

  provisioner "remote-exec" {
    inline = [
      "echo",
    ]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.ssh_key_private} provision.yml"
  }
}