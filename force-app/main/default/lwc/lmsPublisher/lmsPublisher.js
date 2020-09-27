import { LightningElement, wire} from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContactList'
import { publish, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/recordSelected__c';
export default class LmsPublisher extends LightningElement {

    contactList ;
    error;
    
    contacts = [
        {
            Id: '0036F00003ETk2SQAT',
            Name: 'Amy Taylor',
            Title: 'VP of Engineering',
            Phone: '6172559632',
            Picture__c:
                'https://s3-us-west-1.amazonaws.com/sfdc-demo/people/amy_taylor.jpg'
        },
        {
            Id: '003192301009134555',
            Name: 'Michael Jones',
            Title: 'VP of Sales',
            Phone: '6172551122',
            Picture__c:
                'https://s3-us-west-1.amazonaws.com/sfdc-demo/people/michael_jones.jpg'
        },
        {
            Id: '003848991274589432',
            Name: 'Jennifer Wu',
            Title: 'CEO',
            Phone: '6172558877',
            Picture__c:
                'https://s3-us-west-1.amazonaws.com/sfdc-demo/people/jennifer_wu.jpg'
        }
    ];
        
   /* @wire(getContacts)
    contacts({ error, data }) {
        if (data) {
            this.contactList = JSON.stringify(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contactList = undefined;
        }
    } */

    @wire(MessageContext)
        messageContext;

    handleRecordId(event){
        const payload = { recordId: event.target.dataset.recordid };
        publish(this.messageContext, RECORD_SELECTED_CHANNEL, payload);
    }
}