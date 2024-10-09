data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/ecs_trigger"
  output_path = "${path.module}/ecs_trigger.zip"
}

resource "aws_lambda_function" "ecs_trigger" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "ecs_trigger"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  timeout       = 59

  environment {
    variables = {
      CLUSTER_NAME    = aws_ecs_cluster.cluster_ebcdi_ascii.name
      TASK_DEFINITION = aws_ecs_task_definition.conversor_ebcdic_ascii.arn
      ASCII_BUCKET    = aws_s3_bucket.ascii_bucket.id
      CPY_FILE        = var.reference_copybook
      SUBNET          = jsonencode("${data.aws_subnets.default.ids}")
    }
  }
}

# ------------------------ IAM ------------------------ #
# Policy de execução
resource "aws_iam_role" "lambda_role" {
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

resource "aws_iam_role_policy_attachment" "attach_logging_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ecs_invoke_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ecs_invoke.arn
}
