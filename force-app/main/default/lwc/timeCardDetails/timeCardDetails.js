import { LightningElement, api , wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {getRecord,createRecord,getFieldValue} from  'lightning/uiRecordApi';
import project_field from '@salesforce/schema/Employee_Detail__c.Project__c';
import getCurrentMonth from '@salesforce/apex/ErpClass.getMonth'
const fields = [project_field];
export default class TimeCardDetails extends NavigationMixin(LightningElement) {
    @api recordId;
    timeCardDate;
    entTime;
    @track emp;
    month;
    @track project;
    type;

    connectedCallback(){
        alert('recordId is' +this.recordId);
        
        this.emp = this.recordId;
        var d = new Date();
        var n = d.toLocaleString('default', { month: 'long' }); 
       // this.month = n;
       
        getCurrentMonth({Month : n })
        .then(result=>{
            this.month = result;
        }).catch(error=>{
            this.month = error;
        })
        
            
   }

    @wire(getRecord, { recordId: '$recordId', fields })
    empProjects;

    

    fromChangeDateHandler(event){
        this.timeCardDate = event.target.value;
    }
    


    getTime(event){
        this.entTime = event.target.value;
    }
    typehandleChange(event){
        this.type = event.detail.value;
    }
     get options() {
        return [
            { label: 'Development', value: 'Development' },
            { label: 'Project management', value: 'Project management' },
            { label: 'Testing', value: 'Testing' },
            { label: 'Admin Work', value: 'Admin Work' }
        ];
    }
    
        
        handleClick(){
            this.project =  getFieldValue(this.empProjects.data, project_field);
            alert('project is' +this.project);
            alert('Month is' +this.month);
            const fields = {'Date__c': this.timeCardDate, 'Employee_Detail__c' : this.emp,
                         'Type__c': this.type, 
                         'Project__c': this.project,
                       'Time__c' : this.entTime, 'Status__c':  'Submitted'};
        alert(JSON.stringify(fields));

         const recordInput = { apiName:'Time_Card_Details__c' , fields };

        createRecord(recordInput).then(response=>{
            alert('Record Input');
            const evt = new ShowToastEvent({
                title: 'Time card Submitted ',
                message: 'you succesfull created the time record',
                variant: 'Success',
            });
            this.dispatchEvent(evt);

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Employee_Detail__c',
                    actionName: 'view'
                },
            });

        
        }).catch(error =>{
           
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'ERROR',
            });
            this.dispatchEvent(evt);
        })
        }
        
}
