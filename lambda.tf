# Compacta a pasta com o código do script que dispara a task no ECS
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/ecs_trigger"
  output_path = "${path.module}/ecs_trigger.zip"
}

# Cria a função Lambda que dispara a task no ECS usando o código zipado
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
      CPY_FILE        = var.reference_copybook
      SUBNET          = jsonencode("${data.aws_subnets.default.ids}")
      INPUT_FOLDER    = "${var.input_folder}"
      OUTPUT_FOLDER   = "${var.output_folder}"
    }
  }
}
