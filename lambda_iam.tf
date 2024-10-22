# ------------------------ Roles ------------------------ #
# Role de execução
resource "aws_iam_role" "lambda_ecs_role" {
  name = "${terraform.workspace}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com",
      },
    }],
  })
}

# ------------------------ Policies ------------------------ #
# Policy que permite a criação de logs
resource "aws_iam_policy" "logging_policy" {
  name = "${terraform.workspace}-logging-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ],
      Effect   = "Allow",
      Resource = "arn:aws:logs:*:*:*",
    }],
  })
}

# Policy que permite invocar uma task ECS
resource "aws_iam_policy" "lambda_ecs_invoke" {
  name = "${terraform.workspace}-ecs-invoke"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

# ------------------------ Attachments ------------------------ #
# Vincula as policies a role de execução
resource "aws_iam_role_policy_attachment" "attach_logging_policy" {
  role       = aws_iam_role.lambda_ecs_role.name
  policy_arn = aws_iam_policy.logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_invoke_policy" {
  role       = aws_iam_role.lambda_ecs_role.name
  policy_arn = aws_iam_policy.lambda_ecs_invoke.arn
}
