import json
import boto3
import re


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
            # TODO: Implementar chamada do Glue aqui
        else:
            msg = "Some file parts are not present. Glue job not started."

        response = {"statusCode": 200, "body": json.dumps(msg)}
        print(response)
        return response
    except Exception as e:
        response = {"statusCode": 500, "body": json.dumps(f"Error: {e}")}
        print(response)
        return response
