# -------------------------- EBCDIC -------------------------- #
# Bucket que recebe os arquivos EBCDIC
resource "aws_s3_bucket" "ebcdic-bucket" {
  bucket = "${lower(terraform.workspace)}-ebcdic-bucket-${random_string.random_id.result}"
}

# Sobe os arquivos cobol e ebcdic pro bucket de entrada
resource "aws_s3_object" "source_code" {
  bucket = aws_s3_bucket.ebcdic-bucket.id

  for_each     = fileset("sample_data/", "**/*.*")
  key          = each.value
  source       = "sample_data/${each.value}"
  content_type = each.value
}

# --------------------------- ASCII --------------------------- #
# Bucket que guarda os arquivos convertidos pra ASCII
resource "aws_s3_bucket" "ascii_bucket" {
  bucket = "${lower(terraform.workspace)}-ascii-bucket-${random_string.random_id.result}"
}


# ------------------------ IAM ------------------------ #
# Permissão pro S3 acionar a função lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  source_arn    = aws_s3_bucket.ebcdic-bucket.arn
  principal     = "s3.amazonaws.com"
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_trigger.function_name
}

# Evento do bucket de entrada para acionar o Lambda em novos uploads
resource "aws_s3_bucket_notification" "s3_notification" {
  depends_on = [aws_s3_object.source_code]
  bucket     = aws_s3_bucket.ebcdic-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ecs_trigger.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
