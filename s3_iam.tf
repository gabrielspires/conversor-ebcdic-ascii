# Permissão pro S3 acionar a função lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  source_arn    = aws_s3_bucket.ebcdic-bucket.arn
  principal     = "s3.amazonaws.com"
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bin_to_ascii.function_name
}
