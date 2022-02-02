terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "s3" {
    bucket         = "terraform-tfstate-nasini"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-tfstate-nasini"
  }
  required_version = ">= 0.14.9"
}

//Setear la cuenta de NASINI
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
  assume_role{
    role_arn = "${var.workspace_iam_roles[terraform.workspace]}"
  }
}



variable "workspace_iam_roles" {
  default = {
    dev    = "arn:aws:iam::152835622754:role/OrganizationAccountAccessRole"
    prod = "arn:aws:iam::348847601284:role/Terraform-FullAccess"
  }
}