import {LightningElement, api, track, wire} from 'lwc';
import getJbpGoals from '@salesforce/apex/CAJBP_BusinessStrategicGoals.getJbpCustomGoals';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {NavigationMixin} from "lightning/navigation";
import NAME from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.Name';

const COLUMNS = [
    {label: 'Title', fieldName: 'title'},
    {label: 'Description', fieldName: 'description', type: 'text'}/*,
    {label: 'Created By', fieldName: 'createdByName', type: 'text'}*/
];

const DEFAULT_MAX_ROWS = 200;

const JBP_FIELDS = [
    NAME
];

/*
* Returns all Business Strategic Goals for a particular Joint Business Plan, mainly used as a related list
* component on the Joint Business Plan to show all goal records.
*/
export default class CAJBP_RelatedBusinessStrategicGoals extends NavigationMixin(LightningElement) {
    @api
    recordId = null;
    @api
    rows = DEFAULT_MAX_ROWS;
    @api
    year = null;
    @api
    clt = null;
    @track
    businessGoals = [];
    @track
    columns = COLUMNS;
    @track
    recordName = null;
    @track
    jbpHomeUrl = null;
    @track
    jbpRecordUrl = null;
    @track
    isLoading = true;


    constructor() {
        super();
    }

    /*
    * Trigger goals once the Joint Business Plan is loaded.
    */
    @wire(getRecord, {recordId: '$recordId', fields: JBP_FIELDS})
    getBusinessGoals({error, data}) {
        if (error) {
            console.error(error);
            this.isLoading = false;
        }

        if (data) {
            this.recordName = getFieldValue(data, NAME);

            //Generate a link to jbp home list.
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'CAJBP_Joint_Business_Plan__c',
                    actionName: 'list'
                }
            })
            .then((url) => {
                this.jbpHomeUrl = url;
            });

            //Generate a link to jbp record.
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'CAJBP_Joint_Business_Plan__c',
                    actionName: 'view'
                }
            })
            .then((url) => {
                this.jbpRecordUrl = url;
            });

            const that = this;

            (async function() {
                try {
                    that.businessGoals = [...await getJbpGoals({jbpid : that.recordId, year: that.year, clt: that.clt, rows: that.rows})];
                } catch(error) {
                    console.error(error);
                }

                that.isLoading = false;
            })();
        }
    }

    disable(event) {
        event.preventDefault();
        return false;
    }

    get title() {
        return (`Business Strategic Goals (${this.businessGoals.length})`);
    }

    recordHome(event) {
        event.preventDefault();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'CAJBP_Joint_Business_Plan__c',
                actionName: 'view'
            }
        });
    }
}