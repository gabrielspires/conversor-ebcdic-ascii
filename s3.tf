# -------------------------- EBCDIC -------------------------- #
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

# --------------------------- ASCII --------------------------- #
# Bucket que guarda os arquivos convertidos pra ASCII
resource "aws_s3_bucket" "ascii_bucket" {
  bucket = "${lower(terraform.workspace)}-ascii-bucket-${random_string.random_id.result}"
}
