# TODO: Filtrar quando o evento é de criação de pasta
import json
import boto3
import os


def run_task(event, context):
    # Separa os dados relevantes do evento recebido do s3
    s3_event: dict = event["Records"][0]["s3"]
    bucket_name: str = s3_event["bucket"]["name"]
    file_key: str = s3_event["object"]["key"]
    file_size = s3_event["object"]["size"]
    origin = file_key.split("/")[0]

    # Dispara uma função diferente dependendo de onde o arquivo veio
    if file_key.startswith(os.getenv("INPUT_FOLDER")) and file_size > int(os.getenv("FILE_SIZE_LIMIT")):
        task_to_run = "DIVIDE"
    else:
        task_to_run = "CONVERT"

    # Define os parâmetros pra execução da task ECS
    cluster_name = os.getenv("CLUSTER_NAME")
    task_definition_arn = os.getenv("TASK_DEFINITION")

    container_env = [
        {"name": "FUNCTION", "value": task_to_run},
        {"name": "PART_SIZE_MB", "value": os.getenv("FILE_SIZE_LIMIT")},
        {"name": "EBCDIC_BUCKET", "value": bucket_name},
        {"name": "EBCDIC_FILE", "value": file_key},
        {"name": "CPY_FILE", "value": os.getenv("CPY_FILE")},
        {"name": "INPUT_FOLDER", "value": os.getenv("INPUT_FOLDER")},
        {"name": "PARTS_FOLDER", "value": os.getenv("PARTS_FOLDER")},
        {"name": "OUTPUT_KEY", "value": file_key.replace(origin, os.getenv("OUTPUT_FOLDER"))},
    ]

    try:
        # Executa a task do ECS
        ecs_client = boto3.client("ecs")
        response = ecs_client.run_task(
            cluster=cluster_name,
            taskDefinition=task_definition_arn,
            launchType="FARGATE",
            count=1,
            platformVersion="LATEST",
            networkConfiguration={
                "awsvpcConfiguration": {
                    "subnets": eval(os.getenv("SUBNET")),
                    "assignPublicIp": "ENABLED",
                }
            },
            overrides={
                "containerOverrides": [
                    {
                        "name": "conversor-ebcdic-ascii",
                        "environment": container_env,
                    }
                ]
            },
        )

        return {
            "statusCode": 200,
            "body": json.dumps(f"Tarefa ECS iniciada para processar o arquivo {bucket_name}/{file_key}"),
            "event": event,
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Erro ao iniciar a tarefa ECS: {str(e)}"),
            "event": event,
        }
