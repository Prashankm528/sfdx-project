import {LightningElement, api, track, wire} from 'lwc';
import saveSwots from '@salesforce/apex/CAJBP_ObjectiveSwots.saveSwots';
import getSwotOptions from '@salesforce/apex/CAJBP_ObjectiveSwots.getSwotOptions';
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class CAJBP_ObjectiveSwots extends LightningElement {
    @api
    jbpId = null;
    @api
    objectiveId = null;
    //Columns config for swots.
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
            cellAttributes: {
                iconName: {
                    fieldName: 'iconName'
                },
                iconPosition: 'left'
            }}, {
            label: 'Type',
            fieldName: 'type',
            type: 'text',
            sortable: 'true',
            fixedWidth: 160
        }];

        (async function() {
            try {
                that.data = await getSwotOptions({
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
        return this.template.querySelector('.objective-swots-table').getSelectedRows().map(item => item.id);
    }

    @api
    async save(objectiveId) {
        const recordId = (objectiveId || this.objectiveId);
        console.log('Calling objective swots save...... : ' + recordId);

        try {
            await saveSwots({objectiveId: recordId, swotIdsToInsert: this.selected});
            this.dispatchEvent(new CustomEvent('success'));
        } catch(ex) {
            this.dispatchEvent(new CustomEvent('error', {detail: ex}));
        }
    }
}