// Cloud Resume Challenge - Visitor Counter
// TODO: Replace with your API Gateway endpoint URL from Terraform output
// Example: https://abc123.execute-api.us-east-2.amazonaws.com/visitors
const API_ENDPOINT = "https://REPLACE_WITH_API_GATEWAY_ENDPOINT/visitors";

async function updateVisitorCount() {
    try {
        const response = await fetch(API_ENDPOINT);
        if (!response.ok) {
            throw new Error(`HTTP error: ${response.status}`);
        }
        const data = await response.json();
        const countEl = document.getElementById("visitor-count");
        if (countEl) {
            countEl.textContent = data.views;
        }
    } catch (err) {
        // Fail silently — do not break the page if the counter is unavailable
        console.error("Visitor counter unavailable:", err);
    }
}

updateVisitorCount();
