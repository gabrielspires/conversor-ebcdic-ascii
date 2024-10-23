import boto3
import sys
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import *
from awsglue.context import GlueContext
from awsglue.job import Job


def processa_arquivo(spark_df):
    # TODO: Implementar o processamento de cada arquivo aqui
    pass


# Cria a sessão Spark e o contexto do job Glue
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Otimiza a movimentação dos dados entre o Pandas e Spark
spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "true")

# Interpreta os argumentos enviados ao job
args = getResolvedOptions(sys.argv, ["bucket", "files"])
args["files"] = eval(args["files"])
print("Bucket:", args["bucket"])
print("Files:", args["files"])

# Lê cada arquivo no S3 e coloca em um DataFrame Spark
for file in args["files"]:
    sdf = spark.read.parquet(f"s3://{args['bucket']}/{file}")
    print(file)
    sdf.show(n=1)

    processa_arquivo(sdf)
