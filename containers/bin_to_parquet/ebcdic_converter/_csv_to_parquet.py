import os
import sys
import json
import pandas as pd


def csv_to_parquet():
    print("Convertendo arquivo de saída para parquet...")
    json_file = sys.argv[1]

    with open(json_file) as jf:
        cpy_dict = json.load(jf)
        ascii_file = cpy_dict["output"]

    bucket_name = os.getenv("EBCDIC_BUCKET")
    output_key = os.getenv("OUTPUT_KEY")

    s3_url = f"s3://{bucket_name}/{output_key}.parquet"

    df = pd.read_csv(ascii_file, sep="|", header=None)
    try:
        df.to_parquet(s3_url, index=False)
    except Exception as e:
        print("Erro ao salvar parquet:", e)


if __name__ == "__main__":
    csv_to_parquet()
