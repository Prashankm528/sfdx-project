import { LightningElement, api , wire, track } from 'lwc';
import getLeaveRecord from '@salesforce/apex/ErpClass.getLeaveDetails'
export default class LeaveHistory extends LightningElement {
    @api emp;
    @track leaves;
    error;

    @wire(getLeaveRecord, {employeeID :'$emp'})
    LeaveRecord({error, data}){
        if(data){
            
            this.leaves = data;
            this.error = undefined;

        }else if(error){
            
            this.error = error;
            this.leaves = undefined;
        }
    }
}