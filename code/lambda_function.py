import json
import mysql.connector
import boto3
import string
import random
import logging
import os

db_host = os.environ['host_ip']
db_user = os.environ['db_user']
db_password = os.environ['db_password']
db_name = os.environ['db_name']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')
dynamodb_client = boto3.client('dynamodb')
# bucket_name = ''.join(random.choices(string.ascii_lowercase, k=5))

def lambda_handler(event, context):

    logger.info(event)
    path = event['path']    
    httpMethod = event['httpMethod']

    print(db_host)
    print(db_user)
    print(db_password)
    print(db_name)

    try:
        
        db_connection = mysql.connector.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name,
            auth_plugin='mysql_native_password'
        )

        if httpMethod == 'GET' and path == '/s3':
            try:
                cursor = db_connection.cursor()
                select_query = "SELECT * FROM s3"
                cursor.execute(select_query)
                results = cursor.fetchall()
                return {
                    'statusCode': 200,
                    'body': json.dumps(results)
            }
            except Exception as e:
                logger.error('Error querying database: %s', e)
                return {
                    'statusCode': 500,
                    'body': f'Error querying database: {str(e)}'
                }
        
        if httpMethod == 'GET' and path == '/dynamodb':
            try:
                cursor = db_connection.cursor()
                select_query = "SELECT * FROM dynamodb"
                cursor.execute(select_query)
                results = cursor.fetchall()
                return {
                    'statusCode': 200,
                    'body': json.dumps(results)
            }
            except Exception as e:
                logger.error('Error querying database: %s', e)
                return {
                    'statusCode': 500,
                    'body': f'Error querying database: {str(e)}'
                }

        
        elif httpMethod=="POST" and path == '/s3':
            try:

                requested_body = json.loads(event['body'])
                bucket_name = requested_body.get('bucket_name')

                s3_client.create_bucket(Bucket=bucket_name, ACL='private')
                print('bucket created successfully')

                cursor = db_connection.cursor()
                insert_query = 'INSERT INTO s3 (name) VALUES (%s)'
                insert_values= (bucket_name,) 
                cursor.execute(insert_query,insert_values)
                db_connection.commit()
                print('Bucket details inserted into table')

                return{
                    'statusCode' : 200,
                    'body' : json.dumps('%s-bucket created successfully and Inserted into Table' %(bucket_name))
                }
            except Exception as e:
                logger.error('Error creating S3 bucket or inserting into database: %s', e)
                return {
                    'statusCode': 500,
                    'body': f'Error creating S3 bucket or inserting into database: {str(e)}'
                }
        
        elif httpMethod=="POST" and path == '/dynamodb':
            try:
                requested_body = json.loads(event['body'])
                table_name = requested_body['table_name']
                partition_key = requested_body['partition_key']

                attribute_definitions = [
                {
                    'AttributeName': partition_key,
                    'AttributeType': 'S'
                }]
                key_schema = [
                {
                    'AttributeName': partition_key,
                    'KeyType': 'HASH'
                }]

                dynamodb_client.create_table(
                        TableName=table_name,
                        KeySchema=key_schema,
                        AttributeDefinitions=attribute_definitions,
                        ProvisionedThroughput={
                            'ReadCapacityUnits': 5,
                            'WriteCapacityUnits': 5
                        }
                    )
            
                logger.info(f'DynamoDB table {table_name} created successfully')

                cursor = db_connection.cursor()
                insert_query = "INSERT INTO dynamodb (name) VALUES (%s)"
                insert_values = (table_name,)
                cursor.execute(insert_query, insert_values)
                db_connection.commit()
                logger.info(f'Table name {table_name} inserted into MySQL')
                
                return {
                    'statusCode': 200,
                    'body': f'New DynamoDB table {table_name} created and inserted into MySQL'
                }
            
            except Exception as e:
                logger.error(f'Error creating new DynamoDB table or inserting into MySQL: {e}')
                return {
                    'statusCode': 500,
                    'body': f'Error creating new DynamoDB table or inserting into MySQL: {str(e)}'
                }

        else:
            return{
                'statusCode': 405,
                'body' : 'Method not allowed'
            }
    
    except Exception as e:
        logger.error('Error processing request: %s', e)
        return {
            'statusCode': 500,
            'body': f'Error processing request: {str(e)}'
        }
    
    finally:
        if db_connection.is_connected():
            db_connection.close()
            logger.info('Database connection closed')
