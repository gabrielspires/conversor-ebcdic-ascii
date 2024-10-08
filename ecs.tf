# Repositório ECR que recebe a imagem Docker
resource "aws_ecr_repository" "repositorio-ebcdic-ascii" {
  name = "repositorio-ebcdic-ascii"
}

# Cluster ECS
resource "aws_ecs_cluster" "cluster-ebcdi-ascii" {
  name = "cluster-ebcdi-ascii"
}

# Definição de tarefa ECS com o script Python
resource "aws_ecs_task_definition" "conversor-ebcdic-ascii" {
  family = "conversor-ebcdic-ascii"

  # Roda o script que faz o build da imagem Docker e sobe no repositório ECR
  provisioner "local-exec" {
    command     = "bash ${var.script_name} ${aws_ecr_repository.repositorio-ebcdic-ascii.repository_url}"
    working_dir = path.module
  }

  container_definitions = <<DEFINITION
  [
    {
      "name": "conversor-ebcdic-ascii",
      "image": "${aws_ecr_repository.repositorio-ebcdic-ascii.repository_url}",
      "essential": true,
      "environment": [
        {
          "name": "EBCDIC_BUCKET",
          "value": "${aws_s3_bucket.ebcdic-bucket.id}"
        },
        {
          "name": "ASCII_BUCKET",
          "value": "${aws_s3_bucket.ascii_bucket.id}"
        },
        {
          "name": "EBCDIC_FILE",
          "value": "..."
        },
        {
          "name": "CPY_FILE",
          "value": "..."
        },
        {
          "name": "AWS_REGION",
          "value": "${var.region}"
        },
        {
          "name": "AWS_ACCESS_KEY",
          "value": "..."
        },
        {
          "name": "AWS_SECRET_ACCESS_KEY",
          "value": "..."
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.ebcdic-ecs-task.name}",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ebcdic-to-ascii"
        }
      },
      "memory": 4096,
      "cpu": 2048
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add the AWS VPN network mode as this is required for Fargate
  memory                   = 4096        # Specify the memory the container requires
  cpu                      = 2048        # Specify the CPU the container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  depends_on               = [aws_ecr_repository.repositorio-ebcdic-ascii]
}

# Grupo de logs onde a saída do container é gravada
resource "aws_cloudwatch_log_group" "ebcdic-ecs-task" {
  name = "/ecs/s3-ecs-task"
}

# IAM
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
