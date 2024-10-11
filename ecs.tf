# Repositório ECR que recebe a imagem Docker
resource "aws_ecr_repository" "repositorio_ebcdic_ascii" {
  name = "repositorio-ebcdic-ascii"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.cluster_ebcdi_ascii.id
  task_definition = aws_ecs_task_definition.conversor_ebcdic_ascii.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}

# Cluster ECS
resource "aws_ecs_cluster" "cluster_ebcdi_ascii" {
  name = "cluster-ebcdi-ascii"
}

# Definição de tarefa ECS com o script Python
resource "aws_ecs_task_definition" "conversor_ebcdic_ascii" {
  family                   = "conversor-ebcdic-ascii"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 4096
  cpu                      = 2048
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  depends_on               = [aws_ecr_repository.repositorio_ebcdic_ascii]

  ephemeral_storage {
    size_in_gib = 200
  }

  # Roda o script que faz o build da imagem Docker e sobe no repositório ECR
  provisioner "local-exec" {
    command     = "bash ${var.push_bin_to_ascii_image_to_ecr} ${aws_ecr_repository.repositorio_ebcdic_ascii.repository_url} ${var.region}"
    working_dir = path.module
  }

  container_definitions = jsonencode(
    [
      {
        "name" : "conversor-ebcdic-ascii",
        "image" : "${aws_ecr_repository.repositorio_ebcdic_ascii.repository_url}",
        "essential" : true,
        "environment" : [
          {
            "name" : "AWS_REGION",
            "value" : "${var.region}"
          },
        ],
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : "${aws_cloudwatch_log_group.ecs_log_group.name}",
            "awslogs-region" : "${var.region}",
            "awslogs-stream-prefix" : "${aws_cloudwatch_log_stream.ecs_log_stream.name}"
          }
        },
        "memory" : 4096,
        "cpu" : 2048
      }
  ])
}
