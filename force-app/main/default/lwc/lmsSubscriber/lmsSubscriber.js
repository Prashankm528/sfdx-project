import { LightningElement, wire } from 'lwc';
import {subscribe,unsubscribe,APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/RecordId__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';

const fields = [
    NAME_FIELD,
    TITLE_FIELD,
    PHONE_FIELD,
    EMAIL_FIELD,
    
];
export default class LmsSubscriber extends LightningElement {

    subscription = false;
    recordId;
    @wire(MessageContext)
          messageContext;

          @wire(getRecord, { recordId: '$recordId', fields })
         contact;

        get name() {
            return getFieldValue(this.contact.data, NAME_FIELD);
        }
    
        get phone() {
            return getFieldValue(this.contact.data, PHONE_FIELD);
        }
    
        get industry(){
            return getFieldValue(this.contact.data, TITLE_FIELD);
        }
        
        get owner() {
            return getFieldValue(this.contact.data, EMAIL_FIELD);
        }
          
    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        this.recordId = message.recordId;
       
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = false;
    }
}