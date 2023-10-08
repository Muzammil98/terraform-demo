terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    region="us-east-1"
}

resource "aws_instance" "demo-instance" {
    ami             ="ami-0bb4c991fa89d4b9b"
    instance_type   ="t2.micro"

    user_data                   = file("ec2-user-data.sh")
    user_data_replace_on_change = true

    vpc_security_group_ids = [aws_security_group.demo-sg-terraform.id]
    tags = {
        Name = "terraform web server"
    }
}

resource "aws_security_group" "demo-sg-terraform" {
    name = "terraform-example-instance"

    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}