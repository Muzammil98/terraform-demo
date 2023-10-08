terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-s3-bucket-meuzi"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
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

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-s3-bucket-meuzi"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}