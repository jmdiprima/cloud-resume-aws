"""Shared pytest fixtures for backend tests."""

import os
import sys

import pytest

# Add backend/lambda to sys.path so visitor_counter can be imported directly.
# Direct dotted import (from backend.lambda.visitor_counter) is not possible
# because "lambda" is a Python reserved keyword.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "lambda"))


@pytest.fixture
def api_gateway_event() -> dict:
    """Generate a sample API Gateway proxy event."""
    return {
        "httpMethod": "GET",
        "path": "/count",
        "headers": {
            "origin": "https://resume.julesdiprima.com",
        },
        "requestContext": {},
        "body": None,
    }
