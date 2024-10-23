import json
import boto3
import re


def start_glue_job(bucket_name: str, obj_list: list[str]):
    glue = boto3.client("glue")
    glue_job_name = "processamento-de-tabelas-ebcdic"
    job_arguments = {"--bucket": bucket_name, "--files": repr(obj_list)}

    glue_response = glue.start_job_run(JobName=glue_job_name, Arguments=job_arguments)

    job_run_id = glue_response["JobRunId"]

    try:
        return f"Job Glue disparado com sucesso. JobRunId: {job_run_id}"

    except Exception as e:
        return f"Erro ao disparar o job Glue: {str(e)}"


def lambda_handler(event, context):
    # Captura as informações do evento
    s3_event: dict = event["Records"][0]["s3"]
    bucket_name: str = s3_event["bucket"]["name"]
    file_key: str = s3_event["object"]["key"]
    prefix = "/".join(file_key.split("/")[:-1]) + "/"

    print(s3_event)

    try:
        # Conecta no S3 de origem do evento e lista os arquivos
        s3 = boto3.client("s3")
        folder_contents = s3.list_objects(Bucket=bucket_name, Prefix=prefix)["Contents"]
        obj_list = [obj["Key"] for obj in folder_contents]

        # Se o arquivo de flag está presente o job já foi iniciado
        if prefix + "_SENT_TO_GLUE" in obj_list:
            return

        re_match = re.match(
            r"^(?P<file_name>.*)_parte_[0-9]+_de_(?P<num_parts>[0-9]+)(?P<file_suffix>.*)$", obj_list[0]
        )

        file_name = re_match["file_name"]
        num_parts = int(re_match["num_parts"])
        file_suffix = re_match["file_suffix"]

        expected_files = [
            f"{file_name}_parte_{str(part_num)}_de_{str(num_parts)}{file_suffix}"
            for part_num in range(1, num_parts + 1)
        ]
        all_parts_present = all([file in obj_list for file in expected_files])

        if all_parts_present:
            msg = "All file parts are present, starting Glue job..."

            # Chama o job Glue
            glue_status = start_glue_job(bucket_name, obj_list)

            # Salva um arquivo de flag pra marcar que o ebcdic ja foi enviado pro Glue
            s3.put_object(Body="SUCCESS", Bucket=bucket_name, Key=prefix + "_SENT_TO_GLUE")
        else:
            msg = "Some file parts are not present. Glue job not started."

        response = {"statusCode": 200, "body": {"msg": msg, "glue_status": glue_status}}
        print(response)
        return response
    except Exception as e:
        response = {"statusCode": 500, "body": json.dumps(f"Error: {e}")}
        print(response)
        return response
