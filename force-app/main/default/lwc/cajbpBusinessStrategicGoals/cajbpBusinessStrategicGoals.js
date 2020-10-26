import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import getJbpGoals from '@salesforce/apex/CAJBP_BusinessStrategicGoals.getJbpGoals';
import YEAR from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.CAJBP_Year__c';
import CLT from '@salesforce/schema/CAJBP_Joint_Business_Plan__c.CAJBP_CLT__c';

const JBP_FIELDS = [
    YEAR,
    CLT
];

const DEFAULT_MAX_ROWS = 5;

/*
* Renders a set of Business Strategic Goals for a particular Joint Business Plan.
*/
export default class CAJBP_BusinessStrategicGoals extends NavigationMixin(LightningElement) {
    @api
    recordId;
    @api
    rows = DEFAULT_MAX_ROWS;
    @api
    delay = 1000;
    @track
    businessGoals = [];
    @track
    isLoading = true;
    @track
    viewAllUrl = null;
    //Count of total rows returned by server.
    totalRows = 0;


    constructor() {
        super();
    }

    connectedCallback() {
    }

    /*
    * Trigger goals once the Joint Business Plan is loaded.
    */
    @wire(getRecord, {recordId: '$recordId', fields: JBP_FIELDS})
    getBusinessGoals({error, data}) {
        this.isLoading = true;

        if (error) {
            console.error(error);
            this.isLoading = false;
        }

        if (data) {
            const year = getFieldValue(data, YEAR);
            const clt = getFieldValue(data, CLT);

            //Generate a link to the view all page.
            const viewAllPage = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__CAJBP_BusinessStrategicGoals'
                },
                state: {
                    'c__recordId': this.recordId,
                    'c__year': year,
                    'c__clt': clt
                }
            };

            this[NavigationMixin.GenerateUrl](viewAllPage)
                .then((url) => {
                    this.viewAllUrl = url;
                });

            //Get business goals after a delay, due to Joint Business Plan intro animation.
            window.setTimeout(async () => {
                try {
                    const goals = await getJbpGoals({jbpid : this.recordId, year: year, clt: clt, rows: this.rows});
                    this.totalRows = goals.length;
                    this.businessGoals = [...goals.slice(0, this.rows)];
                } catch(error) {
                    console.error(error);
                }

                this.isLoading = false;
            }, this.delay);
        }
    }

    get hasGoals() {
        return this.businessGoals.length > 0;
    }

    get title() {
        const goalSize = this.businessGoals.length;
        return (goalSize > 0 ? `Business Strategic Goals (${goalSize}${goalSize < this.totalRows ? '+' : ''})` : `Business Strategic Goals`);
    }

    get viewAll() {
        return this.hasGoals;
    }
}