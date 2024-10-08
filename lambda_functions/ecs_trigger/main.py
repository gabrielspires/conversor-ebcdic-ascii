import json


def lambda_handler(event: dict, context):
    # TODO: Filtrar quando o evento é de criação de pasta
    for new_record in event.get("Records"):
        print("Bucket:", new_record.get("s3").get("bucket").get("name"))
        print("Object:", new_record.get("s3").get("object").get("key"))
    print(context)
    return {"statusCode": 200, "body": "ECS TRIGGER"}
