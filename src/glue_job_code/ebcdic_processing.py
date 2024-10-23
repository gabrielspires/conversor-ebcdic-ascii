import boto3
import sys
from awsglue.dynamicframe import DynamicFrame
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import *
from awsglue.context import GlueContext
from awsglue.job import Job


def processa_arquivo(arquivo: str):
    pass


sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

# Optimize the data movement from pandas to Spark DataFrame and back
spark.conf.set("spark.sql.execution.arrow.pyspark.enabled", "true")

args = getResolvedOptions(sys.argv, ["bucket", "files"])
args["files"] = eval(args["files"])
print(args)

# You can define a distributed Spark DataFrame, to read the data in a distributed way and be able to process large data
# Here it takes a bit of time because we ask it to infer schema, in practice could just let it set everything as string
# and handle the schema manually

for file in args["files"]:
    sdf = spark.read.parquet(f"s3://{args['bucket']}/{file}")
    print(file)
    sdf.show(n=1)
    # TODO: Implementar o processamento de cada arquivo aqui
