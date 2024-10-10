# TODO: Filtrar quando o evento é de criação de pasta
import json
import boto3
import os


def lambda_handler(event, context):
    ecs_client = boto3.client("ecs")

    # Separa os dados relevantes do evento recebido do s3
    s3_event = event["Records"][0]["s3"]
    bucket_name = s3_event["bucket"]["name"]
    file_key: str = s3_event["object"]["key"]

    # Define os parâmetros pra execução da task ECS
    cluster_name = os.getenv("CLUSTER_NAME")
    task_definition_arn = os.getenv("TASK_DEFINITION")

    # Executa a task do ECS
    try:
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
                        "environment": [
                            {"name": "EBCDIC_BUCKET", "value": bucket_name},
                            {"name": "EBCDIC_FILE", "value": file_key},
                            {
                                "name": "CPY_FILE",
                                "value": os.getenv("CPY_FILE"),
                            },
                            {
                                "name": "OUTPUT_KEY",
                                "value": file_key.replace(
                                    os.getenv("INPUT_FOLDER"),
                                    os.getenv("OUTPUT_FOLDER"),
                                ),
                            },
                        ],
                    }
                ]
            },
        )

        return {
            "statusCode": 200,
            "body": json.dumps(
                f"Tarefa ECS iniciada para processar o arquivo {bucket_name}/{file_key}"
            ),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(f"Erro ao iniciar a tarefa ECS: {str(e)}"),
        }
