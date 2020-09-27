import { LightningElement,wire } from 'lwc';
import {subscribe,unsubscribe,APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/recordSelected__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';

const field = [
    NAME_FIELD,
    TITLE_FIELD,
    PHONE_FIELD,
    EMAIL_FIELD,
    
];

export default class LmsSubscriber extends LightningElement {

    contactList;
    error;
    subscription = false;
    recordId;
    @wire(MessageContext)
    messageContext;
          
    connectedCallback() {
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

    @wire(getRecord, { recordId: '$recordId', fields:field })
    wiredRecord({ error, data }) {
        if (data) {
            this.contactList = JSON.stringify(data);
            this.name = this.contactList.fields.Name.value;
            this.phone = this.contactList.fields.Phone.value
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contactList = undefined;
        }
    }

    handleMessage(message) {
        this.recordId = message.recordId;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}