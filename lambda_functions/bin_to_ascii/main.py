# TODO: Filtrar quando o evento é de criação de pasta
import json
import boto3
import os


def run_task(event, context):
    print("Disparando evento que inicia task de conversão pra ASCII")
    ecs_client = boto3.client("ecs")

    # Separa os dados relevantes do evento recebido do s3
    s3_event = event["Records"][0]["s3"]
    bucket_name = s3_event["bucket"]["name"]
    file_key: str = s3_event["object"]["key"]

    task_to_run = ""
    if file_key.startswith(os.getenv("INPUT_FOLDER")):
        task_to_run = "DIVIDE"
    elif file_key.startswith(os.getenv("PARTS_FOLDER")):
        task_to_run = "CONVERT"

    # Define os parâmetros pra execução da task ECS
    cluster_name = os.getenv("CLUSTER_NAME")
    task_definition_arn = os.getenv("TASK_DEFINITION")

    # Saída pra ver nos logs do CloudWatch
    print("Bucket responsavel pelo evento:", bucket_name)
    print("Arquivo criado:", file_key)
    print("Copybook usado como referencia:", os.getenv("CPY_FILE"))
    print("Pasta de entrada:", os.getenv("PARTS_FOLDER"))
    print("Pasta de saida:", os.getenv("OUTPUT_FOLDER"))
    print("Cluster ECS responsavel pela tarefa:", cluster_name)
    print("Tarefa a ser disparada:", task_definition_arn)

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
                            {"name": "FUNCTION", "value": task_to_run},
                            {"name": "PART_SIZE_MB", "value": "100"},
                            {"name": "EBCDIC_BUCKET", "value": bucket_name},
                            {"name": "EBCDIC_FILE", "value": file_key},
                            {
                                "name": "CPY_FILE",
                                "value": os.getenv("CPY_FILE"),
                            },
                            {
                                "name": "INPUT_FOLDER",
                                "value": os.getenv("INPUT_FOLDER"),
                            },
                            {
                                "name": "PARTS_FOLDER",
                                "value": os.getenv("PARTS_FOLDER"),
                            },
                            {
                                "name": "OUTPUT_KEY",
                                "value": file_key.replace(
                                    os.getenv("PARTS_FOLDER"),
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
