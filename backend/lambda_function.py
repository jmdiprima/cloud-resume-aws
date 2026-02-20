import json
import os
import boto3

# DynamoDB table name — must match the resource defined in infra/template.yaml.
TABLE_NAME = os.environ.get("TABLE_NAME", "cloud-resume-challenge")

# CORS headers returned with every response.
CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
}


def _get_table():
    """Return the DynamoDB Table resource (lazy init for testability)."""
    dynamodb = boto3.resource("dynamodb")
    return dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Increment the visitor counter stored in DynamoDB and return the new value.

    DynamoDB schema:
        Table: cloud-resume-challenge
        Partition key: id  (String)
        Item:  { "id": "1", "views": <Number> }
    """
    table = _get_table()

    # Atomically increment the 'views' attribute by 1.
    # '#v' is an expression attribute name alias for 'views' (avoids reserved-word conflicts).
    # UpdateItem with ADD creates the attribute if it does not yet exist.
    response = table.update_item(
        Key={"id": "1"},
        UpdateExpression="ADD #v :inc",
        ExpressionAttributeNames={"#v": "views"},
        ExpressionAttributeValues={":inc": 1},
        ReturnValues="UPDATED_NEW",
    )

    count = int(response["Attributes"]["views"])

    return {
        "statusCode": 200,
        "headers": CORS_HEADERS,
        "body": json.dumps({"count": count}),
    }
