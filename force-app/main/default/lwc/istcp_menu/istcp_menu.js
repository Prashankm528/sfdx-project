import { LightningElement } from 'lwc';

export default class Istcp_menu extends LightningElement {
    myAccountsState = "slds-hide";
    myAccountsOpen = false;
    marketsInsightsState = "slds-hide";
    marketsInsightsOpen = false;

    changeMyAccountsState() {
        if (this.myAccountsState == "slds-hide") {
            this.myAccountsState = "slds-show";
            this.myAccountsOpen = true;
        } else {
            this.myAccountsState = "slds-hide";
            this.myAccountsOpen = false;
        }
    }

    changeMarketInsightsState() {
        console.log('inside changeMarketInsightsState', this.marketsInsightsState);
        if (this.marketsInsightsState == "slds-hide") {
            this.marketsInsightsState = "slds-show";
            this.marketsInsightsOpen = true;
        } else {
            this.marketsInsightsState = "slds-hide";
            this.marketsInsightsOpen = false;
        }
    }
}