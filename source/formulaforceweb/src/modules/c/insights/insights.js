import { LightningElement } from 'lwc';
import { getInsights } from 'stubs/insights'; 

export default class Insights extends LightningElement {

    // Component state and bindings
    insight = {};
    loginButtonLabel = '';
    insightsLoaded = false;

    // Call /api/insights API once the component is loaded
    connectedCallback() {
        getInsights().then((result) => {
            this.insight = result;
            this.loginButtonLabel = this.insight.partnerStatus ? 'Partner Logout' : 'Partner Login';
            this.insightsLoaded = true;
        });
    }

    // Handles partner login and logout navigation (server side redirects return the user to main page)
    handlePartnerLogin(event) {
        var loginUrl = this.insight.partnerStatus !=null ? '/oauth2/logout' : 'oauth2/auth';
        window.location.href = loginUrl;
    }
}
