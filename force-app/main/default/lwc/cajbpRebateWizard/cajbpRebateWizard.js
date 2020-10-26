/*
 * @author			Venkatesh Muniyasamy
 * @date			04/10/2019
 * @group			CAJBP
 * @description		Renders Rebate fields based on the recordtype choosen
 *
 * history
 * 14/08/2019	Amir Hafeez			    Created POC
 * 04/10/2019	Venkatesh Muniyasamy	Implemented the Component
 * 20/11/2019   Venkatesh Muniyasamy    Modified the component for Volume Percentage
 * 06/02/2019   Venkatesh Muniyasamy    Modified the component for JBP Currency Assigment and reformating
 * 21/02/2019   Venkatesh Muniyasamy    Updated for Custom Label
 */

import {LightningElement, api, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LOCALE from '@salesforce/i18n/locale';
import pplvolumepercentage from '@salesforce/label/c.CAJBP_PPL_Volume_Percentage';
import pplother from '@salesforce/label/c.CAJBP_PPL_Other';
import ppllabel from '@salesforce/label/c.CAJBP_PPL_Label';
import turnoverlabel from '@salesforce/label/c.CAJBP_Turnover_Label';
import turnoverpercentage from '@salesforce/label/c.CAJBP_Turnover_Help_Text_Percentage';

export default class RebateWizard extends LightningElement {
    @track _scoreCardId;
    @track _currencyId;
    @api recordTypeId;
    @track _recordTypeValues;
    @track _recordId;
    @track isLoading = true;
    @track isNew = true;
    @track isSaving = false;
    @track targetAmount;
    @track thresholdAmount;
    @track stretchAmount;
    @track targetTurnover;
    label = {pplvolumepercentage,pplother,ppllabel,turnoverlabel,turnoverpercentage};

    @api get recordTypeValues()
    {   return this._recordTypeValues;    }
    set recordTypeValues(value)
    {   this._recordTypeValues = value;   }
   @api get recordRebateId()
    {    return this._recordId;    }
    set recordRebateId(value)
    {   this._recordId = value;    }
    @api get scoreCardId()
    {    return this._scoreCardId;    }
    set scoreCardId(value)
    {    this._scoreCardId = value;    }
    @api get currencyId()
    {   return this._currencyId;    }
    set currencyId(value)
    {   this._currencyId = value;   }

    get isSingleVolumePPL() {
        return this._recordTypeValues.toString().search('Single') >= 0
                    &&  this._recordTypeValues.toString().search('PPL')>=0
                    &&  this._recordTypeValues.toString().search('Volume')>=0;
    }
    get isMultipleVolumePPL() {
        return this._recordTypeValues.toString().search('Multiple') >= 0
                    &&  this._recordTypeValues.toString().search('PPL')>=0
                    &&  this._recordTypeValues.toString().search('Volume')>=0;
    }
    get isSingleTurnoverPercentage() {
        return this._recordTypeValues.toString().search('Single') >= 0
                    &&  this._recordTypeValues.toString().search('Percentage')>=0
                    &&  this._recordTypeValues.toString().search('Turnover')>=0;
    }
    get isMultipleTurnoverPercentage() {
        return this._recordTypeValues.toString().search('Multiple') >= 0
                    &&  this._recordTypeValues.toString().search('Percentage')>=0
                    &&  this._recordTypeValues.toString().search('Turnover')>=0;
    }
    get isSingleVolumePercentage()
    {
        return this._recordTypeValues.toString().search('Single') >= 0
                    &&  this._recordTypeValues.toString().search('Percentage')>=0
                    &&  this._recordTypeValues.toString().search('Volume')>=0;
    }
    get isMultipleVolumePercentage()
    {
        return this._recordTypeValues.toString().search('Multiple') >= 0
                    &&  this._recordTypeValues.toString().search('Percentage')>=0
                    &&  this._recordTypeValues.toString().search('Volume')>=0;
    }
    connectedCallback()
    {
        if(this._recordId)
        {this.isNew = false;}
    }
    saveRebate(event)
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

    handleLoad() {
        this.isLoading = false;

        if(this.isSingleVolumePPL)
        this.setSingleRebatePPLValues();

        if(this.isMultipleVolumePPL)
        this.setMultipleRebatePPLValues();

        if(this.isSingleTurnoverPercentage)
        this.setSingleRebatePercentageValues();

        if(this.isMultipleTurnoverPercentage)
        this.setMultipleRebatePercentageValues();

        if(this.isSingleVolumePercentage)
        this.setSingleRebateVolumePercentage();

        if(this.isMultipleVolumePercentage)
        this.setMultipleRebateVolumePercentage();

        if(this._recordId)
        {this.isNew = false;}

        const rebateEvent = new CustomEvent('rebateloaded');
        this.dispatchEvent(rebateEvent);
    }

    setSingleRebatePPLValues()
    {
        this.template.querySelector('.targetppl').value =this.template.querySelector('.target-price-per-litre').value;
        this.targetAmount = this.template.querySelector('.target-amount-ppl').value;

        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.targetamountppl').value = totalTargetAmount.format(this.targetAmount);
    }

    setMultipleRebatePPLValues()
    {
        this.setSingleRebatePPLValues();
        this.template.querySelector('.thresholdppl').value =this.template.querySelector('.threshold-price-per-litre').value;
        this.thresholdAmount = this.template.querySelector('.threshold-amount-ppl').value;

        const thresholdTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.thresholdamountppl').value = thresholdTargetAmount.format(this.thresholdAmount);

        this.template.querySelector('.stretchppl').value =this.template.querySelector('.stretch-price-per-litre').value;
        this.stretchAmount = this.template.querySelector('.stretch-amount-ppl').value;

        const stretchTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.stretchamountppl').value = stretchTargetAmount.format(this.stretchAmount);
    }

    setSingleRebatePercentageValues()
    {
        this.template.querySelector('.targetturnover').value =this.template.querySelector('.target-turnover').value;
        this.targetAmount = this.template.querySelector('.target-amount-percentage').value;

        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.targetamountpercentage').value = totalTargetAmount.format(this.targetAmount);
    }

    setMultipleRebatePercentageValues()
    {
        this.setSingleRebatePercentageValues();
        this.template.querySelector('.thresholdturnover').value =this.template.querySelector('.threshold-turnover').value;
        this.targetAmount = this.template.querySelector('.threshold-amount-percentage').value;

        const totalThresholdAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.thresholdamountpercentage').value = totalThresholdAmount.format(this.targetAmount);

        this.template.querySelector('.stretchturnover').value =this.template.querySelector('.stretch-turnover').value;
        this.targetAmount = this.template.querySelector('.stretch-amount-percentage').value;

        const totalStretchAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.stretchamountpercentage').value = totalStretchAmount.format(this.targetAmount);
    }

    setSingleRebateVolumePercentage()
    {
        this.template.querySelector('.targetppl').value =this.template.querySelector('.target-price-per-litre').value;
        this.targetTurnover = this.template.querySelector('.target-turnover').value;
        this.targetAmount = this.template.querySelector('.target-amount').value;

        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.targetamount').value = totalTargetAmount.format(this.targetAmount);
        this.template.querySelector('.targetturnover').value = totalTargetAmount.format(this.targetTurnover);
    }

    setMultipleRebateVolumePercentage()
    {
        this.setSingleRebateVolumePercentage();
        this.template.querySelector('.thresholdppl').value =this.template.querySelector('.threshold-price-per-litre').value;
        this.thresholdTurnover = this.template.querySelector('.threshold-turnover').value;
        this.thresholdAmount = this.template.querySelector('.threshold-amount').value;

        const totalThresholdAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.thresholdamount').value = totalThresholdAmount.format(this.thresholdAmount);
        this.template.querySelector('.thresholdturnover').value = totalThresholdAmount.format(this.thresholdTurnover);

        this.template.querySelector('.stretchppl').value =this.template.querySelector('.stretch-price-per-litre').value;
        this.stretchTurnover = this.template.querySelector('.stretch-turnover').value;
        this.stretchAmount = this.template.querySelector('.stretch-amount').value;

        const totalStretchAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.stretchamount').value = totalStretchAmount.format(this.stretchAmount);
        this.template.querySelector('.stretchturnover').value = totalStretchAmount.format(this.stretchTurnover);
    }

    cancelRebate()
    {
        const cancelEvent = new CustomEvent('cancelrebate');
        this.dispatchEvent(cancelEvent);
    }

    backRebate()
    {
        const backEvent = new CustomEvent('backrebate');
        this.dispatchEvent(backEvent);
    }

    handleSuccess()
    {
        const rebEvent = new ShowToastEvent({
            "title": "Success!", "message": "The Rebate has been saved successfully.",
            'variant': 'success'
        });
        this.dispatchEvent(rebEvent);
        const rebateEvent = new CustomEvent('rebatecreated');
        this.dispatchEvent(rebateEvent);
    }

    checkThresholdRebatePPL()
    {
        const volume = this.template.querySelector('.threshold-volume').value;
        const ppu = this.template.querySelector('.thresholdppl').value;

        if (volume === null || ppu === null) {
            this.thresholdAmount = 0.00;
        } else {
            this.thresholdAmount =  volume * ppu;
        }
        const thresholdTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.thresholdamountppl').value = thresholdTargetAmount.format(this.thresholdAmount) ;
        this.template.querySelector('.threshold-price-per-litre').value = ppu;
        this.template.querySelector('.threshold-amount-ppl').value = this.thresholdAmount;
    }

    checkTargetRebatePPL()
    {
        const volume = this.template.querySelector('.target-volume').value;
        const ppu = this.template.querySelector('.targetppl').value;

        if (volume === null || ppu === null) {
            this.targetAmount = 0.00;
        } else {
            this.targetAmount =  volume * ppu;
        }
        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.targetamountppl').value = totalTargetAmount.format(this.targetAmount) ;
        this.template.querySelector('.target-price-per-litre').value = ppu;
        this.template.querySelector('.target-amount-ppl').value = this.targetAmount;
    }

    checkStretchRebatePPL()
    {
        const volume = this.template.querySelector('.stretch-volume').value;
        const ppu = this.template.querySelector('.stretchppl').value;

        if (volume === null || ppu === null) {
            this.stretchAmount = 0.00;
        } else {
            this.stretchAmount =  volume * ppu;
        }

        const totalStretchAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.stretchamountppl').value = totalStretchAmount.format(this.stretchAmount) ;
        this.template.querySelector('.stretch-price-per-litre').value = ppu;
        this.template.querySelector('.stretch-amount-ppl').value = this.stretchAmount;
    }

    checkTargetRebatePercentage()
    {
        const turnover = this.template.querySelector('.targetturnover').value;
        const percentage = this.template.querySelector('.target-percentage').value;

        if (turnover === null || percentage === null) {
            this.targetAmount = 0.00;
        } else {
            this.targetAmount =  turnover * percentage/100;
        }
        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.targetamountpercentage').value = totalTargetAmount.format(this.targetAmount) ;
        this.template.querySelector('.target-turnover').value = turnover;
        this.template.querySelector('.target-amount-percentage').value = this.targetAmount;
    }

    checkThresholdRebatePercentage()
    {
        const turnover = this.template.querySelector('.thresholdturnover').value;
        const percentage = this.template.querySelector('.threshold-percentage').value;

        if (turnover === null || percentage === null) {
            this.thresholdAmount = 0.00;
        } else {
            this.thresholdAmount =  turnover * percentage/100;
        }
        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.thresholdamountpercentage').value = totalTargetAmount.format(this.thresholdAmount) ;
        this.template.querySelector('.threshold-turnover').value = turnover;
        this.template.querySelector('.threshold-amount-percentage').value = this.thresholdAmount;
    }

    checkStretchRebatePercentage()
    {
        const turnover = this.template.querySelector('.stretchturnover').value;
        const percentage = this.template.querySelector('.stretch-percentage').value;

        if (turnover === null || percentage === null) {
            this.stretchAmount = 0.00;
        } else {
            this.stretchAmount =  turnover * percentage/100;
        }
        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});
        this.template.querySelector('.stretchamountpercentage').value = totalTargetAmount.format(this.stretchAmount) ;
        this.template.querySelector('.stretch-turnover').value = turnover;
        this.template.querySelector('.stretch-amount-percentage').value = this.stretchAmount;
    }

    checkTargetRebateVolumeTurnover()
    {
        const volume = this.template.querySelector('.target-volume').value;
        const ppl = this.template.querySelector('.targetppl').value;
        const percentage = this.template.querySelector('.target-percentage').value;

        if(volume === null || ppl === null)
        {
            this.targetTurnover =0.00;
        }
        else
        {
            this.targetTurnover = volume*ppl;

            if(this.targetTurnover === null || percentage === null)
            {
                this.targetAmount = 0.00;
            }
            else
            {
                this.targetAmount = volume*ppl*percentage/100;
            }
        }
        const totalTargetAmount = new Intl.NumberFormat(LOCALE,{   style:'currency',
                                                                currency:this._currencyId,
                                                                currencyDisplay:'symbol'});

        this.template.querySelector('.targetamount').value = totalTargetAmount.format(this.targetAmount);
        this.template.querySelector('.target-amount').value = this.targetAmount;
        this.template.querySelector('.targetturnover').value = totalTargetAmount.format(this.targetTurnover);
        this.template.querySelector('.target-turnover').value = this.targetTurnover;
        this.template.querySelector('.target-price-per-litre').value = ppl;
    }

    checkThresholdRebateVolumeTurnover()
    {
        const volume = this.template.querySelector('.threshold-volume').value;
        const ppl = this.template.querySelector('.thresholdppl').value;
        const percentage = this.template.querySelector('.threshold-percentage').value;

        if(volume === null || ppl === null)
        {
            this.thresholdTurnover =0.00;
        }
        else
        {
            this.thresholdTurnover = volume*ppl;

            if(this.thresholdTurnover === null || percentage === null)
            {
                this.thresholdAmount = 0.00;
            }
            else
            {
                this.thresholdAmount = volume*ppl*percentage/100;
            }
        }
        const totalThresholdAmount = new Intl.NumberFormat(LOCALE,{   style:'currency', currency:this._currencyId,
                                                                    currencyDisplay:'symbol'});

        this.template.querySelector('.thresholdamount').value = totalThresholdAmount.format(this.thresholdAmount);
        this.template.querySelector('.threshold-amount').value = this.thresholdAmount;
        this.template.querySelector('.thresholdturnover').value = totalThresholdAmount.format(this.thresholdTurnover);
        this.template.querySelector('.threshold-turnover').value = this.thresholdTurnover;
        this.template.querySelector('.threshold-price-per-litre').value = ppl;
    }

    checkStretchRebateVolumeTurnover()
    {
        const volume = this.template.querySelector('.stretch-volume').value;
        const ppl = this.template.querySelector('.stretchppl').value;
        const percentage = this.template.querySelector('.stretch-percentage').value;

        if(volume === null || ppl === null)
        {
            this.stretchTurnover =0.00;
        }
        else
        {
            this.stretchTurnover = volume*ppl;

            if(this.stretchTurnover === null || percentage === null)
            {
                this.stretchAmount = 0.00;
            }
            else
            {
                this.stretchAmount = volume*ppl*percentage/100;
            }
        }
        const totalStretchAmount = new Intl.NumberFormat(LOCALE,{   style:'currency', currency:this._currencyId,
                                                                    currencyDisplay:'symbol'});

        this.template.querySelector('.stretchamount').value = totalStretchAmount.format(this.stretchAmount);
        this.template.querySelector('.stretch-amount').value = this.stretchAmount;
        this.template.querySelector('.stretchturnover').value = totalStretchAmount.format(this.stretchTurnover);
        this.template.querySelector('.stretch-turnover').value = this.stretchTurnover;
        this.template.querySelector('.stretch-price-per-litre').value = ppl;
    }
}