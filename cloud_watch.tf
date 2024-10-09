# Grupo de logs onde a saída do container ECS é gravada
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/s3-ecs-task"
}

resource "aws_cloudwatch_log_stream" "ecs_log_stream" {
  name           = "ecs_log_stream"
  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
}
