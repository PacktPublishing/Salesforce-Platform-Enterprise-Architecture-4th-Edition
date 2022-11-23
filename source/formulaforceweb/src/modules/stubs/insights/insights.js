// Endpoint for this client stub
const URL = '/api/insights/';
let insights = {};

/**
 * Simple client stub for the /api/insights API
 */
export const getInsights = () =>
    fetch(URL)
        .then((response) => {
            if (!response.ok) { throw new Error('No response from server'); }
            return response.json();
        })
        .then((result) => {
            insights = result;
            return insights;
        });
