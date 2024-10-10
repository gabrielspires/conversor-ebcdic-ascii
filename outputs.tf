output "ebcdic_bucket" {
  description = "Bucket que recebe os arquivos brutos e guarda os processados"
  value       = aws_s3_bucket.ebcdic-bucket.id
}

output "lambda_function" {
  description = "Função Lambda que dispara a task no ECS"
  value       = aws_lambda_function.ecs_trigger.function_name
}

output "default_vpc" {
  description = "VPC padrão usada nos serviços criados"
  value       = data.aws_vpc.default.id
}

output "default_subnets" {
  description = "Subnets padrão usadas na VPC"
  value       = data.aws_subnets.default.ids
}

output "sec_group" {
  description = "Security Group usado na VPC"
  value       = aws_security_group.ecs_security_group.id
}

output "ecr_repository" {
  description = "Repositório de imagens criado no ECR"
  value       = aws_ecr_repository.repositorio_ebcdic_ascii.id
}

output "ecs_service" {
  description = "Serviço ECS criado pra task de conversão"
  value       = aws_ecs_service.ecs_service.name
}

output "ecs_cluster" {
  description = "Cluster ECS que contém as tasks definidas"
  value       = aws_ecs_cluster.cluster_ebcdi_ascii.id
}

output "ecs_task" {
  description = "Task do ECS que faz a conversão dos arquivos EBCDIC"
  value       = aws_ecs_task_definition.conversor_ebcdic_ascii.id
}
