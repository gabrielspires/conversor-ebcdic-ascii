# Bucket que recebe os arquivos EBCDIC
resource "aws_s3_bucket" "ebcdic-bucket" {
  bucket = "${lower(terraform.workspace)}-ebcdic-bucket-${random_string.random_id.result}"
}

# Sobe os arquivos cobol e ebcdic pro bucket de entrada
resource "aws_s3_object" "source_code" {
  bucket       = aws_s3_bucket.ebcdic-bucket.id
  for_each     = fileset("sample_data/", "**/*.*")
  key          = each.value
  source       = "sample_data/${each.value}"
  content_type = each.value
}

# Pastas padrão
resource "aws_s3_object" "input_key" {
  bucket = aws_s3_bucket.ebcdic-bucket.id
  key    = "${var.input_folder}/"
}

resource "aws_s3_object" "partitioned_key" {
  bucket = aws_s3_bucket.ebcdic-bucket.id
  key    = "${var.partitioned_folder}/"
}

resource "aws_s3_object" "output_key" {
  bucket = aws_s3_bucket.ebcdic-bucket.id
  key    = "${var.output_folder}/"
}


# Evento do bucket de entrada para acionar o Lambda
resource "aws_s3_bucket_notification" "binary_file_created" {
  depends_on = [aws_s3_object.source_code, aws_lambda_permission.allow_s3_invoke]
  bucket     = aws_s3_bucket.ebcdic-bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.bin_to_ascii.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = aws_s3_object.input_key.key
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.bin_to_ascii.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = aws_s3_object.partitioned_key.key
  }
}
