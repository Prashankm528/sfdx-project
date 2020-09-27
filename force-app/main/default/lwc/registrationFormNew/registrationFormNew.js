import {LightningElement, track, wire } from 'lwc';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import GENDER_FIELD from '@salesforce/schema/Contact.Gender__c';
import DEPT_FIELD from '@salesforce/schema/Contact.Department__c';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import addContact from '@salesforce/apex/ContactController.addContact';
import getContact from '@salesforce/apex/ContactController.getContactList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RegistrationFormNew extends LightningElement {


    @track Firstname = FIRSTNAME_FIELD;
    @track Lastname = LASTNAME_FIELD;
    @track email = EMAIL_FIELD;
    @track gender = GENDER_FIELD;
    @track department = DEPT_FIELD;
    @track contactRecord = [] ;
   

    get options() {
        return [
            { label: 'Male', value: 'Male' },
            { label: 'Female', value: 'Female' },
            { label: 'Transgender', value: 'Transgender' },

        ];
    }

    @wire(getContact)
    contacts(value){
       
        if (value.error) {
            this.errorMsg = value.error;
            
        } else if (value.data) {
            this.contactRecord = value.data;
        }

    }

    rec = {
        Firstname : this.Firstname,
        Lastname : this.Lastname,
        email : this.email,
        gender : this.gender,
       department : this.department.fieldApiName


    }


    handleName(event){
        if(event.target.name == "FirstName"){
            this.rec.Firstname = event.target.value;
            
            
           
        }
        if(event.target.name == "LastName"){
            this.rec.Lastname = event.target.value;
           
            
        }
        if(event.target.name == "Email"){
            this.rec.email = event.target.value;
            
        }    
        if(event.target.name == "radioGroup"){
            this.rec.gender = event.detail.value;
            
        }    
        if(event.target.name == "progress"){
            //this.rec.department = event.detail.value;
            
        } 
    }    
        
    saveRecord(){
        alert('Prashank');
        console(this.rec);
            addContact({
                con : this.rec
            })
            .then(result =>{
                console.log('Record Inserted');
                this.contactRecord = result;
            })
            .catch(error=>{
                console.log('Record failed');
            })
    
}
}