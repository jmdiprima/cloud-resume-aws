"""Visitor counter Lambda function for the Cloud Resume Challenge."""

import json
import os


def handler(event: dict, context: object) -> dict:
    """Handle API Gateway request to increment and return visitor count.

    Args:
        event: API Gateway proxy event.
        context: Lambda context object.

    Returns:
        API Gateway proxy response with visitor count.
    """
    # TODO: Implement DynamoDB get/update and return count
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "https://resume.julesdiprima.com",
        },
        "body": json.dumps({"visitor_count": 0}),
    }
