import os
import boto3
import json
from boto3.dynamodb.conditions import Key, Attr
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb", region_name='eu-west-1', endpoint_url="https://dynamodb.eu-west-1.amazonaws.com")

table = dynamodb.Table(os.environ.get('DYNAMODB_TABLE'))

token = None
bodyjson = None

def response_msg(message, status_code):
    return {
        'statusCode': str(status_code),
        'body': json.dumps(message),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
            }
        }

def lambda_handler(event, context):
    # try:
    #     bodyjson = json.loads(event['body'])
    # except KeyError as e:
    #     returndata = "uuups....."
    #     return response_msg(returndata, 200)
    
    # token = bodyjson.get('tokenid', None)
    # if token == None:
    #     returndata = "haha... kein Code"
    # else:
    #     try:
    #         response_db = table.get_item(
    #             Key={
    #                 'configId': token
    #             }
    #         )
    #     except ClientError as e:
    #         return resonse_msg(e.response['Error']['Message'],200)
        
    #     returndata = response_db.get('Item',None)
    #     if returndata==None:
    #         return response_msg('{"error": "Pech gehabt"}',205)

    # return response_msg(returndata, 200)
    return response_msg(event,200)