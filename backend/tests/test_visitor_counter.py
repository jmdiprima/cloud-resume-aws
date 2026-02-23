"""Tests for the visitor counter Lambda function."""

import json

from visitor_counter import handler


class TestVisitorCounter:
    """Tests for the visitor counter handler."""

    def test_handler_returns_200(self, api_gateway_event: dict) -> None:
        """Verify handler returns HTTP 200 status code."""
        response = handler(api_gateway_event, None)
        assert response["statusCode"] == 200

    def test_handler_returns_valid_json_body(self, api_gateway_event: dict) -> None:
        """Verify response body contains valid JSON with visitor_count."""
        response = handler(api_gateway_event, None)
        body = json.loads(response["body"])
        assert "visitor_count" in body

    def test_handler_cors_header(self, api_gateway_event: dict) -> None:
        """Verify CORS header is set to the specific domain, not wildcard."""
        response = handler(api_gateway_event, None)
        assert response["headers"]["Access-Control-Allow-Origin"] == "https://resume.julesdiprima.com"
