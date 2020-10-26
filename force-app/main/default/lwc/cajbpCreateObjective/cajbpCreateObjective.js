import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import saveObjective from '@salesforce/apex/CAJBP_ObjectiveSwots.saveObjective';
import OBJECTIVE_OBJECT from '@salesforce/schema/CAJBP_Objective__c';
import JBP_NAME_FIELD from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.Name';
import JBP_CURRENCY from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.CurrencyIsoCode';


/*
* Custom component that creates a new Objective and related SWOTs.
*/
export default class CAJBP_CreateObjective extends LightningElement {
    @api
    recordId = null;
    @api
    recordTypeName = 'Objective';
    @track
    jbpRecord = null;
    @track
    objectiveInfo = null;
    @track
    hasFormLoaded = false;
    @track
    hasSwotsLoaded = false;
    @track
    isSaving = false;

    constructor() {
        super();
    }

    connectedCallback() {
    }

    /*
    * Get info about the joint business plan.
    */
    @wire(getRecord, { recordId: '$recordId', fields: [JBP_NAME_FIELD, JBP_CURRENCY]})
    getJbpRecord({error, data}) {
        this.jbpRecord = data;
    }

    /*
    * Get describe info on CAJBP_Objective__c, this is used to determine the correct record type id.
    */
    @wire(getObjectInfo, {objectApiName: OBJECTIVE_OBJECT})
    getObjectiveInfo({error, data}) {
        this.objectiveInfo = data;
    }

    get jbpCurrencyIsoCode() {
        if (this.jbpRecord) {
            return getFieldValue(this.jbpRecord, JBP_CURRENCY);
        }

        return null;
    }

    get jbpName() {
        if (this.jbpRecord) {
            return getFieldValue(this.jbpRecord, JBP_NAME_FIELD);
        }

        return null;
    }

    /*
    * Get back valid record type id for Objective stored in [recordTypeName].
    */
    get recordTypeId() {
        if (this.objectiveInfo && this.objectiveInfo.recordTypeInfos) {
            return Object.keys(this.objectiveInfo.recordTypeInfos).find(item => {
                return this.objectiveInfo.recordTypeInfos[item].name === this.recordTypeName;
            });
        }

        return null;
    }

    handleFormLoaded(event) {
        //Add delay to simulate waiting for form loaded, lookup might still be rendering.
        window.setTimeout(() => this.hasFormLoaded = true, 200);
    }

    handleSwotsLoaded() {
        //Has the related SWOTs been loaded?
        this.hasSwotsLoaded = true;
    }

    cancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    async save(event) {
        event.preventDefault();

        this.isSaving = true;
        const inputs = this.template.querySelectorAll('lightning-input-field');
        //Retrieve the selected SWOT ids.
        const selectedSwots = this.template.querySelector('c-cajbp-objective-swots').selected;

        //Validate all inputs from the objective form.
        const allValid = [...inputs]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.reportValidity();
            }, true);

        if (allValid) {
            //Create objective record.
            let objective = {
                sObjectType: 'CAJBP_Objective__c',
                RecordTypeId: this.recordTypeId
            };

            for (const input of inputs) {
                objective[input.fieldName] = input.value;
            }

            try {
                await saveObjective({
                    objectiveJson: JSON.stringify(objective),
                    swotIdsToInsert: selectedSwots
                });

                this.dispatchEvent(new ShowToastEvent(
                {
                    title: 'Success!',
                    message: 'Objective has been created successfully.',
                    variant: 'success'
                }));

                this.dispatchEvent(new CustomEvent('created'));
            } catch(ex) {
                this.dispatchEvent(new ShowToastEvent(
                    {
                    title: 'Error',
                    message: ex.body.message,
                    variant: 'error',
                    mode: 'sticky'
                }));
            }
        }

        this.isSaving = false;
    }

    get hasRecordLoaded() {
        return this.objectiveInfo && this.recordTypeId && this.recordTypeId.length > 0;
    }

    get showLoading() {
        return !this.isPageReady || this.isSaving;
    }

    get isPageReady() {
        return this.hasRecordLoaded && this.hasFormLoaded && this.hasSwotsLoaded;
    }

    get formCss() {
        return 'animated fadeIn ' + (this.isPageReady ? '' : 'hide');
    }
}