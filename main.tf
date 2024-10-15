terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.7.5"
}

# Configurações do ambiente AWS
provider "aws" {
  region = var.region
}

# Recurso que gera um ID aleatório (útil pra criar id único de bucket)
resource "random_string" "random_id" {
  length  = 8
  upper   = false
  special = false
}
