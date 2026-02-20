"""
Unit tests for lambda_function.py.

Uses moto to mock DynamoDB so no real AWS calls are made.
Run from the backend/ directory: python -m pytest -v
"""
import importlib
import json
import os
import sys
import pytest
import boto3
from moto import mock_aws

# Ensure the backend directory is on the path when tests are run from the repo root
sys.path.insert(0, os.path.dirname(__file__))

TABLE_NAME = "test-visitor-count"
ALLOWED_ORIGIN = "https://julesdiprima.com"


@pytest.fixture(autouse=True)
def aws_env(monkeypatch):
    """Set required environment variables and dummy credentials before each test."""
    monkeypatch.setenv("TABLE_NAME", TABLE_NAME)
    monkeypatch.setenv("ALLOWED_ORIGIN", ALLOWED_ORIGIN)
    monkeypatch.setenv("AWS_ACCESS_KEY_ID", "testing")
    monkeypatch.setenv("AWS_SECRET_ACCESS_KEY", "testing")
    monkeypatch.setenv("AWS_SECURITY_TOKEN", "testing")
    monkeypatch.setenv("AWS_SESSION_TOKEN", "testing")
    monkeypatch.setenv("AWS_DEFAULT_REGION", "us-east-2")


def _create_table(client):
    client.create_table(
        TableName=TABLE_NAME,
        KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
        AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
        BillingMode="PAY_PER_REQUEST",
    )


@mock_aws
def test_returns_200():
    _create_table(boto3.client("dynamodb", region_name="us-east-2"))
    import lambda_function as lf
    importlib.reload(lf)
    result = lf.lambda_handler({}, None)
    assert result["statusCode"] == 200


@mock_aws
def test_cors_header_present():
    _create_table(boto3.client("dynamodb", region_name="us-east-2"))
    import lambda_function as lf
    importlib.reload(lf)
    result = lf.lambda_handler({}, None)
    assert "Access-Control-Allow-Origin" in result["headers"]
    assert result["headers"]["Access-Control-Allow-Origin"] == ALLOWED_ORIGIN


@mock_aws
def test_cors_header_not_wildcard():
    _create_table(boto3.client("dynamodb", region_name="us-east-2"))
    import lambda_function as lf
    importlib.reload(lf)
    result = lf.lambda_handler({}, None)
    assert result["headers"]["Access-Control-Allow-Origin"] != "*"


@mock_aws
def test_view_count_increments():
    _create_table(boto3.client("dynamodb", region_name="us-east-2"))
    import lambda_function as lf
    importlib.reload(lf)
    result1 = lf.lambda_handler({}, None)
    result2 = lf.lambda_handler({}, None)
    body1 = json.loads(result1["body"])
    body2 = json.loads(result2["body"])
    assert body2["views"] == body1["views"] + 1


def test_atomic_update_used(monkeypatch):
    """Verify update_item is called (atomic) — NOT get_item + put_item."""
    update_item_called = []
    get_item_called = []
    put_item_called = []

    class MockTable:
        def update_item(self, **kwargs):
            update_item_called.append(kwargs)
            return {"Attributes": {"views": 1}}

        def get_item(self, **kwargs):
            get_item_called.append(kwargs)
            return {}

        def put_item(self, **kwargs):
            put_item_called.append(kwargs)
            return {}

    class MockDynamoDB:
        def Table(self, name):
            return MockTable()

    monkeypatch.setattr(boto3, "resource", lambda svc, **kw: MockDynamoDB())

    import lambda_function as lf
    importlib.reload(lf)
    lf.lambda_handler({}, None)

    assert len(update_item_called) == 1, "update_item must be called exactly once"
    assert len(get_item_called) == 0, "get_item must NOT be called (use atomic update)"
    assert len(put_item_called) == 0, "put_item must NOT be called (use atomic update)"


@mock_aws
def test_response_body_contains_views():
    _create_table(boto3.client("dynamodb", region_name="us-east-2"))
    import lambda_function as lf
    importlib.reload(lf)
    result = lf.lambda_handler({}, None)
    body = json.loads(result["body"])
    assert "views" in body
    assert isinstance(body["views"], int)
