resource "aws_glue_job" "ebcdic_processing_job" {
  name     = "processamento-de-tabelas-ebcdic"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.ebcdic-bucket.bucket}/glue_job_code/ebcdic_processing.py"
    python_version  = "3"
  }

  default_arguments = {
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.ebcdic-glue-job-log-group.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
  }
}

resource "aws_cloudwatch_log_group" "ebcdic-glue-job-log-group" {
  name              = "ebcdic-glue-job"
  retention_in_days = 30
}
