import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import getContacts from '@salesforce/apex/ContactController.getContactList'
import PASS_RECORD_ID from '@salesforce/messageChannel/RecordId__c'

export default class LmsPublisher extends LightningElement {

    conlist;
    @wire(MessageContext)
        messageContext;

    @wire(getContacts)
    Contacts({data, error}){
        if(data){
            this.conlist = data;
        }
    }
    

    handleRecordId(event){
        alert(event.target.dataset.recordid);
       
        const payload = { recordId: event.target.dataset.recordid };

        publish(this.messageContext, PASS_RECORD_ID, payload);
    }
        
    
}