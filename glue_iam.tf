resource "aws_iam_role" "glue_role" {
  name = "glue-ebcdic-processing-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# ------------------------ Policies ------------------------ #
# Policy que permite a criação de logs
resource "aws_iam_policy" "glue_logging_policy" {
  name = "${terraform.workspace}-glue-logging-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:*",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      Effect   = "Allow",
      Resource = "*",
    }],
  })
}

resource "aws_iam_policy" "glue_policies" {
  name = "${terraform.workspace}-glue-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      "Sid" : "VisualEditor0",
      "Effect" : "Allow",
      "Action" : ["s3:GetObject"],
      "Resource" : "${aws_s3_bucket.ebcdic-bucket.arn}/${aws_s3_object.output_key.key}*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : ["s3:GetObject"],
        "Resource" : "${aws_s3_bucket.ebcdic-bucket.arn}/glue_job_code/*"
      },
      {
        "Sid" : "VisualEditor2",
        "Effect" : "Allow",
        "Action" : ["logs:PutLogEvents"],
        "Resource" : "arn:aws:logs:*:*:*",
    }],
  })

}

# ------------------------ Attachments ------------------------ #
# Vincula as policies a role de execução
resource "aws_iam_role_policy_attachment" "attach_glue_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policies.arn
}

resource "aws_iam_role_policy_attachment" "attach_glue_logging_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_logging_policy.arn
}
