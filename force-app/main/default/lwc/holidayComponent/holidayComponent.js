import { LightningElement, track } from 'lwc';
import getHolidaysRecord from '@salesforce/apex/ErpClass.getHolidays'
const COLS = [   
    {
        label: 'Holiday Name',
        fieldName: 'Holiday__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Week day',
        fieldName: 'MasterLabel',
        type: 'text',
        sortable: true
    },
    {
        label: 'Date',
        fieldName: 'Date_of_Holiday__c',
        type: 'date',
        sortable: true
    }]
export default class HolidayComponent extends LightningElement {
    @track columns = COLS;
    @track data = []
    defaultSortDirection ='asc'
    connectedCallback(){
        this.getHolidays();
    }
    getHolidays(){
        getHolidaysRecord()
        .then(result=>{
            this.data = result;
            
        })
        .catch(error=>{
           
            this.data = undefined;
        })
}
    }


