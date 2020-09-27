import { LightningElement , api ,wire ,track } from 'lwc';

import getContact from '@salesforce/apex/getDetails.getDetailsByCaseId'
//import createContact from '@salesforce/apex/getDetails.createContact'
export default class CustomerDetails extends LightningElement {
    @api caseId;
    @track contactName;
    @track firstname;
    @track LastName ;
    @track emailValue;
    @track Phone;
    conValue = [];

    

    handleClick(){
        alert('Mohit');
        this.dispatchEvent(new CustomEvent('next'));
        
    }

    @wire(getContact, {caseId : '$caseId'}) 
    conName({ error, data }) {
        if (data) {
            alert('Prashank');
            this.contactName = data;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
}
