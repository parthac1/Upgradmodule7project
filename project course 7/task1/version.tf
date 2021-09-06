
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.1"
    }
  }
    backend "s3" {
    bucket = "parthproject7"
    key    = "root/terraform.tfstate"
    region = "us-east-1" 

    dynamodb_table = "parthtable"       
  }
}


provider "aws" {
  region  = var.aws_region
  profile = "default"
}

