terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "weather-states-663354324751"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
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

# Inclui todos os recursos declarados nos .tf da pasta infra
# (Terraform automaticamente lê *.tf do mesmo diretório)