terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }
  }
  backend "s3" {
    bucket = "ekscluster-backend"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
    #dynamodb_table = "eks-lock-table""
    encrypt = true
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}




