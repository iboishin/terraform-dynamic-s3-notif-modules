import boto3

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    response = s3_client.list_buckets()
