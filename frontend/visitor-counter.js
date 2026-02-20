// TODO: Replace with your API Gateway endpoint after deploying the backend stack.
const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/visitors";

/**
 * Fetches the current visitor count from the API and updates the page.
 * The API increments the count on every GET request (atomic update in DynamoDB).
 */
async function updateVisitorCount() {
    const countElement = document.getElementById("visitor-count");
    if (!countElement) return;

    try {
        const response = await fetch(API_URL);
        if (!response.ok) {
            throw new Error(`API returned status ${response.status}`);
        }
        const data = await response.json();
        countElement.textContent = data.count;
    } catch (error) {
        console.error("Failed to fetch visitor count:", error);
        // Show a graceful fallback so the rest of the page is unaffected.
        countElement.textContent = "—";
    }
}

// Run on page load.
updateVisitorCount();
