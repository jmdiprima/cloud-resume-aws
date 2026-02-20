"""
Unit tests for the Lambda visitor-counter function.

Run with:
    pip install pytest boto3 moto
    pytest backend/
"""

import json
import os
import pytest

# Point the function at a test table name before importing the module.
os.environ["TABLE_NAME"] = "cloud-resume-challenge"
os.environ.setdefault("AWS_DEFAULT_REGION", "us-east-1")

import boto3
from moto import mock_aws

from lambda_function import lambda_handler


@pytest.fixture
def dynamodb_table():
    """Create a mock DynamoDB table for each test."""
    with mock_aws():
        client = boto3.client("dynamodb", region_name="us-east-1")
        client.create_table(
            TableName="cloud-resume-challenge",
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        yield


def test_increments_count_from_zero(dynamodb_table):
    """First call should return count == 1."""
    result = lambda_handler({}, None)

    assert result["statusCode"] == 200
    body = json.loads(result["body"])
    assert body["count"] == 1


def test_increments_count_on_subsequent_calls(dynamodb_table):
    """Each call should increment the count by exactly 1."""
    lambda_handler({}, None)  # count -> 1
    lambda_handler({}, None)  # count -> 2
    result = lambda_handler({}, None)  # count -> 3

    assert result["statusCode"] == 200
    body = json.loads(result["body"])
    assert body["count"] == 3


def test_response_has_cors_headers(dynamodb_table):
    """The response must include CORS headers."""
    result = lambda_handler({}, None)

    headers = result.get("headers", {})
    assert "Access-Control-Allow-Origin" in headers
    assert headers["Access-Control-Allow-Origin"] == "*"
    assert "Access-Control-Allow-Methods" in headers


def test_response_body_is_valid_json(dynamodb_table):
    """The response body must be a JSON string with a 'count' key."""
    result = lambda_handler({}, None)

    body = json.loads(result["body"])
    assert "count" in body
    assert isinstance(body["count"], int)
