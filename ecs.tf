data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Repositório ECR que recebe a imagem Docker
resource "aws_ecr_repository" "repositorio_ebcdic_ascii" {
  name = "repositorio-ebcdic-ascii"
}

resource "aws_security_group" "ecs_security_group" {
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    command     = "bash ${var.script_name} ${aws_ecr_repository.repositorio_ebcdic_ascii.repository_url} ${var.region}"
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
            "name" : "ASCII_BUCKET",
            "value" : "${aws_s3_bucket.ascii_bucket.id}"
          },
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

# Grupo de logs onde a saída do container é gravada
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/s3-ecs-task"
}

resource "aws_cloudwatch_log_stream" "ecs_log_stream" {
  name           = "ecs_log_stream"
  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
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

resource "aws_iam_policy" "ecs_permissions" {
  name = "${terraform.workspace}-ecs-permissions"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:CancelRotateSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:StopReplicationToReplica",
          "secretsmanager:ReplicateSecretToRegions",
          "secretsmanager:RestoreSecret",
          "cloudwatch:*",
          "ssm:*",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:RemoveRegionsFromReplication"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.ebcdic-bucket.arn}/*"
      },
      {
        "Sid" : "VisualEditor2",
        "Effect" : "Allow",
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.ascii_bucket.arn}/*"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ecs_permissions_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.ecs_permissions.arn
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
