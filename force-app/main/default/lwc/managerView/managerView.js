import { LightningElement, api, wire, track } from 'lwc';
import getManagerRecord from '@salesforce/apex/ErpClass.getManagerDetails'
import getReporteeRecord from '@salesforce/apex/ErpClass.getReporteeDetails'
import getReporteesLeaves from '@salesforce/apex/ErpClass.getLeaveDetailsEmployee'
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/Time_Card_Details__c.Status__c';
import COMMENTS_FIELD from '@salesforce/schema/Time_Card_Details__c.Manager_Comments__c';
import ID_FIELD from '@salesforce/schema/Time_Card_Details__c.Id';


const COLS = [
    { label: 'Name', fieldName: 'Employee_Detail__c' },
    { label: 'Status', fieldName: 'Status__c', type:'picklist', editable: true },
    { label: 'Date', fieldName: 'Date__c' },
    { label: 'type', fieldName: 'Type__c' },
    { label: 'Comments', fieldName: 'Manager_Comments__c', editable: true }
];
export default class ManagerView extends LightningElement {
    @track leaveId;
    @api emp;
    @track empRecords;
    @track leaveEmpRecords;
    @track reportee;
    @track showData = false;
    @track draftValues = [];
    @track columns = COLS;

    error;

    handleSave(event) {

        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        fields[STATUS_FIELD.fieldApiName] = event.detail.draftValues[0].Status__c;
        fields[COMMENTS_FIELD.fieldApiName] = event.detail.draftValues[0].Manager_Comments__c;

        const recordInput = {fields};

        updateRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contact updated',
                    variant: 'success'
                })
            );
            this.draftValues = [];
            return refreshApex(this.ManageRecord);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });

    }

    @wire(getReporteeRecord ,{employeeID:'$emp'})
    ReporteeRecord({error, data}){
        if(data){
            this.reportee = data;
            this.error = undefined;
        }
        else if(error){
            this.error = error;
            this.reportee = undefined;
        }
    }

    @wire(getManagerRecord ,{employeeID:'$emp'})
    ManageRecord({error, data}){
        if(data){
            this.empRecords = data;
            this.error = undefined;
        }
        else if(error){
            this.error = error;
            this.empRecords = undefined;
        }
    }
    test(){
        
        alert('Prashank');
        this.showData = true;
    }

    @wire(getReporteesLeaves ,{employeeID:'$emp'})
    leavesRecord
    ({error, data}){
        if(data){
            this.leaveEmpRecords = data;
            this.error = undefined;
        }
        else if(error){
            this.error = error;
            this.leaveEmpRecords = undefined;
        }
    }


    leaveRecord(event){
        event.preventDefault();
        alert('Prashank');
        this.leaveId = event.target.dataset.id;
        alert(this.leaveId);
        this.template.querySelector("c-modal-pop-up-lwc").openModal();

    }
}