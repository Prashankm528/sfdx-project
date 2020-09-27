import { LightningElement, api , wire, track} from 'lwc';
import getEmpEmail from '@salesforce/apex/ErpClass.getEmployeeEmail'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {createRecord, getRecord} from  'lightning/uiRecordApi';

const fieldArrays =['Employee_Detail__c.Available_Sick_Leave__c', 'Employee_Detail__c.Available_Vacation_Leave__c',
                    'Employee_Detail__c.Available_Personal_Leave__c']
export default class LeavePlanner extends LightningElement {
    @api emp;
    FromDate;
    toDate;
    Status;
    Type;
    Reason;
    email;
    error;
    empid;
    @track areDetailsVisible = true;

    handleLeave(){
        this.areDetailsVisible = false;
    }

    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }

    @wire(getRecord , {recordId : '$empid' , fields: fieldArrays })
    EmployeeRecord;
    	
    
    get options1() {
        return [
            { label: 'Sick', value: 'Sick' },
            { label: 'Personal', value: 'Personal' },
            { label: 'Vacation', value: 'Vacation' },
        ];
    }

    connectedCallback(){
         this.empid = this.emp;
        this.getEmail()     
    }

    getEmail(){
        getEmpEmail()
        .then(result=>{
            this.email = result;
        }).catch(error=>{
            this.email = error;
        })
        
    }
    
   /*@wire(getEmpEmail, { empId: '$emp' })
    empEmail({error, data}){
        if(data){
            alert(data);
            this.email = data;
            this.error = undefined;
          
        }
        else if(error){
            this.email = undefined;
            this.error = error;
        }
    } */
    

    fromChangeDateHandler(event){
        this.FromDate = event.target.value;
    }

    toChangeDateHandler(event){
        this.toDate = event.target.value;
    }
    statushandleChange(event){
        this.Status = event.detail.value;
        alert(this.Status);
        
    }
    typehandleChange(event){
        this.Type = event.detail.value;
       
    }
    reasonChangeDateHandler(event){
        this.Reason = event.target.value;
    }
    handleClick(){
        const fields = {'Leave_From__c': this.FromDate, 'Leave_To__c' : this.toDate,
                         'Type__c': this.Type, 
                        'Reason_for_Leave__c': this.Reason, 'Employee_Detail__c': this.emp,
                       'email__c' : this.email, 'Status__c':  'Submitted'};
        alert(JSON.stringify(fields));

         const recordInput = { apiName:'Leave_Management__c' , fields };

        createRecord(recordInput).then(response=>{
            alert('Record Input');
            const evt = new ShowToastEvent({
                title: 'Leave Submitted ',
                message: 'Leave Submitted successfully',
                variant: 'Success',
            });
            this.dispatchEvent(evt);

        
        }).catch(error =>{
           
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'ERROR',
            });
            this.dispatchEvent(evt);
        })
        this.areDetailsVisible = true;
      }
        get retSickLeave(){
            if(this.EmployeeRecord.data){
                return this.EmployeeRecord.data.fields.Available_Sick_Leave__c.value ;
            }
            return undefined;

            
        }


        get retVacationLeave(){
            if(this.EmployeeRecord.data){
                return this.EmployeeRecord.data.fields.Available_Vacation_Leave__c.value ;
            }
            return undefined;
        }

        get retPersonalLeave(){
            if(this.EmployeeRecord.data){
                return this.EmployeeRecord.data.fields.Available_Personal_Leave__c.value ;
            }
            return undefined;
        }

        handleUploadFinished(event) {
            // Get the list of uploaded files
            const uploadedFiles = event.detail.files;
            let uploadedFileNames = '';
            for(let i = 0; i < uploadedFiles.length; i++) {
                uploadedFileNames += uploadedFiles[i].name + ', ';
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                    variant: 'success',
                }),
            );
        }

    

}

   
