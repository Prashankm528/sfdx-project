import {LightningElement, api, track, wire} from 'lwc';
import savePriorities from '@salesforce/apex/CAJBP_ObjectiveCustomerPriorities.savePriorities';
import getPrioritiesOptions from '@salesforce/apex/CAJBP_ObjectiveCustomerPriorities.getPrioritiesOptions';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class CAJBPCustomerPriorities extends LightningElement {
    @api
    jbpId = null;
    @api
    objectiveId = null;
    columns = [];
    @track
    data = [];
    @track
    selectedRows = [];
    @track
    sortBy;
    @track
    sortDirection;

    constructor() {
        super();
    }

    connectedCallback() {
        const that = this;

        that.columns = [{
            label: 'Title',
            fieldName: 'title',
            type: 'text',
            sortable: 'true',
            },{
            label: 'Description',
            fieldName: 'description',
            type: 'text',
            sortable: 'true',
            fixedWidth: 160
        }];

        (async function() {
            try {
                that.data = await getPrioritiesOptions({
                    jbpId: that.jbpId,
                    objectiveId: that.objectiveId
                });

                that.selectedRows = that.data.filter(item => item.selected).map(item => item.id);
            } catch(ex) {
                that.dispatchEvent(new ShowToastEvent(
                    {
                    title: 'Error',
                    message: ex.body.message,
                    variant: 'error',
                    mode: 'sticky'
                }));
            }

            that.dispatchEvent(new CustomEvent('loaded'));
        })();
    }

    handleSortData(event) {
        //field name
        this.sortBy = event.detail.fieldName;
        //sort direction
        this.sortDirection = event.detail.sortDirection;
        //calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        //serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));

        //Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        //checking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;

        //sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; //handling null values
            y = keyValue(y) ? keyValue(y) : '';

            //sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        //set the sorted data to data table data
        this.data = parseData;
    }

    @api
    get selected() {
        return this.template.querySelector('.objective-priorities-table').getSelectedRows().map(item => item.id);
    }

    @api
    async save(objectiveId) {
        console.log('Calling objective priorities-----');
        const recordId = (objectiveId || this.objectiveId);
        console.log('Calling objective priorities save...... : ' + recordId);

        try {
            await savePriorities({objectiveId: recordId, priorityIdsToInsert: this.selected});
            this.dispatchEvent(new CustomEvent('success'));
        } catch(ex) {
            this.dispatchEvent(new CustomEvent('error', {detail: ex}));
        }
    }
}