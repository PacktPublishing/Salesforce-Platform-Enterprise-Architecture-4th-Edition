import { LightningElement, track } from 'lwc';
import { getInsights } from 'data/insights'; 

export default class Insights extends LightningElement {
    
    areDetailsVisible = false;
    insight = {};
    loginButtonLabel = '';

    connectedCallback() {
        getInsights().then((result) => {
            this.insight = result;
            this.loginButtonLabel = this.insight.partnerStatus ? 'Partner Logout' : 'Partner Login';
            this.areDetailsVisible = true;
        });
    }

    handlePartnerLogin(event) {
        var loginUrl = this.insight.partnerStatus !=null ? '/oauth2/logout' : 'oauth2/auth';
        window.location.href = loginUrl;
    }
}
