import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isFeatureAccessible from '@salesforce/apex/ISTCP_Utilities.isFeatureAccessible';
import executeTrade from '@salesforce/apex/ISTCP_TradeController.executeTrade';

export default class Istcp_trade extends LightningElement {
    error;
    featureDisabled;
    
    directions = [{label: 'Buy', value: 'Buy'}, {label: 'Sell', value: 'Sell'}];
    maxVolume;
    @api tradeConfiguration;
    @api tradeMode;
    trade;
    volumeUnitOfMeasure = 'Quantity';
    isQuickTrade = false;
    isMoreInfo = false;

    connectedCallback() {
        console.log('inside connectedCallback');

        if (this.tradeMode == 'Enter trade') {
            this.isQuickTrade = true;
            this.isMoreInfo = false;
        } else if (this.tradeMode == 'More information') {
            this.isQuickTrade = false;
            this.isMoreInfo = true;
        }

        this.loadTradeConfiguration();

        isFeatureAccessible({ featureName: 'Quick Trade', userId: null })
        .then((result) => {
            this.error = undefined;
            
            // This feature is accessible by the current user
            if (result === true) {
                this.featureDisabled = false;
            } else {
                this.featureDisabled = true;
            }
        })
        .catch((error) => {
            this.error = error;
            console.error(error);
        });
    }

    handleDirectionChange(event) {
        this.trade.Direction = event.target.value;
    }

    handleQuantityChange(event) {
        this.trade.Quantity = event.target.value;
    }
    
    loadTradeConfiguration() {
        console.log('this.tradeConfiguration', JSON.stringify(this.tradeConfiguration));
        this.trade = {...this.tradeConfiguration};        
        this.trade.Direction = 'Buy';

        if (this.trade.VolumeUnitOfMeasure != undefined || this.trade.VolumeUnitOfMeasure != null || this.trade.VolumeUnitOfMeasure != '') {
            this.volumeUnitOfMeasure = "Quantity (" + this.trade.VolumeUnitOfMeasure + ")";
        }
    }

    handleCancel(event) {
        this.dispatchEvent(new CustomEvent('cancel')); 
    }

    async completeTrade() {

        // Verify all input is valid
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
            
        if (allValid) {

            console.log('trade to be sent to apex: ', JSON.stringify(this.trade));
            let executedTrade = await executeTrade( { trade: this.trade } );
            console.log('executedTrade', JSON.stringify(executedTrade));
            
            let event;
            if (executedTrade.hasOwnProperty('error')) {
                event = new ShowToastEvent({
                    title: 'Error',
                    message: executedTrade.error,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            } else {
                event = new ShowToastEvent({
                    title: 'Trade was created successfully',
                    message: 'Trade Id:' + executedTrade.Id + '   Name:' + executedTrade.Name + '   created on:' + executedTrade.CreatedDate,
                    variant: 'success',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this.handleCancel();
            }
        }
    }
}