terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "weather-states-663354324751"
    key = "data-pipeline/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
 }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}