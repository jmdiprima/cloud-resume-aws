import json
import os
import boto3

# Initialize DynamoDB resource at module level to reuse across warm invocations
dynamodb = boto3.resource("dynamodb")


def lambda_handler(event, context):
    """
    Visitor counter Lambda handler.
    Atomically increments the 'views' counter in DynamoDB and returns the new count.
    Configuration is read from environment variables — nothing is hardcoded.
    """
    table_name = os.environ["TABLE_NAME"]
    allowed_origin = os.environ["ALLOWED_ORIGIN"]

    cors_headers = {
        "Access-Control-Allow-Origin": allowed_origin,
        "Access-Control-Allow-Methods": "GET",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    table = dynamodb.Table(table_name)

    # Atomic increment — avoids the get_item + put_item race condition
    response = table.update_item(
        Key={"id": "visitors"},
        UpdateExpression="ADD #v :inc",
        ExpressionAttributeNames={"#v": "views"},
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )

    views = int(response["Attributes"]["views"])

    return {
        "statusCode": 200,
        "headers": cors_headers,
        "body": json.dumps({"views": views}),
    }
