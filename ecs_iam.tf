# ------------------------ Roles ------------------------ #
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# ------------------------ Policies ------------------------ #
# Permissões gerais pro container acessar serviços da nuvem
resource "aws_iam_policy" "ecs_permissions" {
  name = "${terraform.workspace}-ecs-permissions"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:CancelRotateSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetRandomPassword",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:StopReplicationToReplica",
          "secretsmanager:ReplicateSecretToRegions",
          "secretsmanager:RestoreSecret",
          "cloudwatch:*",
          "ssm:*",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:RemoveRegionsFromReplication"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : ["s3:GetObject"],
        "Resource" : "${aws_s3_bucket.ebcdic-bucket.arn}/*"
      },
      {
        "Sid" : "VisualEditor2",
        "Effect" : "Allow",
        "Action" : ["s3:PutObject"],
        "Resource" : "${aws_s3_bucket.ebcdic-bucket.arn}/${aws_s3_object.partitioned_key.key}*"
      },
      {
        "Sid" : "VisualEditor3",
        "Effect" : "Allow",
        "Action" : ["s3:PutObject"],
        "Resource" : "${aws_s3_bucket.ebcdic-bucket.arn}/${aws_s3_object.output_key.key}*"
      }
    ]
  })

}

# ------------------------ Attachments ------------------------ #
# Vincula as policies a role de execução
resource "aws_iam_role_policy_attachment" "ecs_permissions_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.ecs_permissions.arn
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
