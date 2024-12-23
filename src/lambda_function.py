import json
import boto3
import os
from datetime import datetime
import random

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        # タイムスタンプをIDの一部として使用
        current_time = datetime.now()
        location_id = f"santa_location_{current_time.strftime('%Y%m%d_%H%M%S')}"

        current_location = {
            'id': location_id,  # ユニークなID
            'latitude': str(random.uniform(30.0, 45.0)),
            'longitude': str(random.uniform(128.0, 146.0)),
            'timestamp': current_time.isoformat()
        }

        # DynamoDBに位置情報を保存
        table.put_item(Item=current_location)

        # レスポンスを返す
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Santa location updated successfully',
                'location': current_location
            })
        }
    except Exception as e:
        print(f'Error: {str(e)}')
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Error updating Santa location'
            })
        }