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

  #   environment {
  #     variables = {
  #       CLUSTER_NAME = aws_ecs_cluster.ecs_cluster.name
  #       TASK_DEFINITION = aws_ecs_task_definition.ecs_task.arn
  #     }
  #   }
}

# ------------------------ IAM ------------------------ #
resource "aws_iam_role" "lambda_role" {
  name = "${terraform.workspace}-lambda_execution_role"

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

resource "aws_iam_policy" "logging_policy" {
  name = "${terraform.workspace}-logging_policy"
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

resource "aws_iam_role_policy_attachment" "attach_logging_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.logging_policy.arn
}
