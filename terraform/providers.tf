terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.76.0, <5.92.0"
    }
  }
  required_version = "~>1.11.0"
}

provider "aws" {
  region = "us-east-1"
}
