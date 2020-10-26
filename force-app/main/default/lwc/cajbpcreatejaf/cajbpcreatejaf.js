/**
 * @author			Venkatesh Muniyasamy
 * @date			11/12/2019
 * @group			CAJBP
 * @description		Renders JAF fields based on the recordtype choosen.
 *
 * history
 * 11/12/2019	Venkatesh Muniyasamy	    New JAF
*/
import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord,getFieldValue} from 'lightning/uiRecordApi';
import JBP_NAME_FIELD from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.Name';
import JBP_CURRENCY from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.CurrencyIsoCode';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';

export default class Cajbpcreatejaf extends LightningElement
{
    @api recordId; @track jafName; @track totalJafValue; @track isLoading = true; @track isSaving = false;
    @track
    jbpCurrencyIsoCode = null;
    @track castrolContributionAmount;
    @track partnerContributionAmount;

    @wire(getRecord, { recordId: '$recordId', fields: [JBP_NAME_FIELD, JBP_CURRENCY]})
        jbp;

    @api
    get hasLoaded() {
        if (this.jbp.data) {
            this.jbpCurrencyIsoCode = getFieldValue(this.jbp.data, JBP_CURRENCY);
            this.jafName = getFieldValue(this.jbp.data, JBP_NAME_FIELD).replace('JBP','JAF');
        }

        return (this.jbp && this.jbp.data);
    }

    handleLoad()
    {
        this.isLoading = false;
    }
    handleSuccess()
    {
        this.isSaving = false;

        const successEvent = new ShowToastEvent(
        {
            "title": "Success!",
            "message": this.jafName + " has been created successfully.",
            "variant": "success"
        });

        this.dispatchEvent(successEvent);

        const jafEvent = new CustomEvent('jafcreated');
        this.dispatchEvent(jafEvent);
    }
    handleError(event)
    {
        this.isSaving = false;

        const errorEvent = new ShowToastEvent(
            {
            title: 'Error',
            message: event.detail.detail,
            variant: 'error',
            mode: 'sticky'
        });

        this.dispatchEvent(errorEvent);
    }
    cancelJAF()
    {
        const cancelEvent = new CustomEvent('canceljaf');
        this.dispatchEvent(cancelEvent);
    }
    saveJAF(event)
    {
        event.preventDefault();

        const allValid = [...this.template.querySelectorAll('lightning-input-field'),...this.template.querySelectorAll('lightning-input')]
                    .reduce((validSoFar, inputCmp) =>
                    {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.reportValidity();
                    },true);

        if(allValid)
        {
            this.isSaving = this.isLoading = true;
            const fields = event.detail.fields;
            this.template.querySelector('.lightning-record-edit-form').submit(fields);
        }
    }
    calculatetotalfund()
    {
        const castrol = this.template.querySelector('.castrolcontribution').value || 0;
        const partner = this.template.querySelector('.partnercontribution').value || 0;

        if(castrol == null || partner == null)
        {
            this.totalJafValue = 0.00
        }
        else
        {
            this.castrolContributionAmount = parseFloat(castrol);
            this.partnerContributionAmount = parseFloat(partner);
            this.totalJafValue = parseFloat(castrol) + parseFloat(partner);
        }
        const totalJafFormat = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this.jbpCurrencyIsoCode,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.totalJafInput').value = totalJafFormat.format(this.totalJafValue) ;
    }

    @api
    get hideCss() {
        return (this.hasLoaded ? '' : 'hide');
    }
}