# Compacta a pasta com o código do script que dispara a task no ECS
data "archive_file" "bin_to_parquet" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/bin_to_parquet"
  output_path = "${path.module}/lambda_functions/bin_to_parquet.zip"
}

# Cria a função Lambda que dispara a task no ECS usando o código zipado
resource "aws_lambda_function" "bin_to_parquet" {
  filename      = data.archive_file.bin_to_parquet.output_path
  function_name = "bin_to_parquet"
  role          = aws_iam_role.lambda_ecs_role.arn
  handler       = "main.run_task"
  runtime       = "python3.9"
  timeout       = 60

  environment {
    variables = {
      CLUSTER_NAME    = aws_ecs_cluster.cluster_ebcdi_ascii.name
      TASK_DEFINITION = aws_ecs_task_definition.conversor_ebcdic_ascii.arn
      CPY_FILE        = var.reference_copybook
      SUBNET          = jsonencode("${data.aws_subnets.default.ids}")
      INPUT_FOLDER    = "${var.input_folder}"
      PARTS_FOLDER    = "${var.partitioned_folder}"
      OUTPUT_FOLDER   = "${var.output_folder}"
      FILE_SIZE_LIMIT = "${var.file_size_limit * 1024 * 1024}"
    }
  }
}

# Compacta a pasta com o código do script que envia os arquivos pro Glue
data "archive_file" "parquet_to_glue" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/parquet_to_glue"
  output_path = "${path.module}/lambda_functions/parquet_to_glue.zip"
}

resource "aws_lambda_function" "send_binary_to_glue" {
  filename      = data.archive_file.parquet_to_glue.output_path
  function_name = "inicia_processo_glue_autorizador"
  role          = aws_iam_role.lambda_glue_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60

  environment {
    variables = {
      ENV = ""
    }
  }

}
