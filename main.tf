terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70.0"
    }
  }

  required_version = ">= 1.9.7"
}

# Configurações do ambiente AWS
provider "aws" {
  region = var.region
  # access_key = ""
  # secret_key = ""
}

# Recurso que gera um ID aleatório (útil pra criar id único de bucket)
resource "random_string" "random_id" {
  length  = 8
  upper   = false
  special = false
}
