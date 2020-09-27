import { LightningElement } from 'lwc';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactCreator extends LightningElement {
    objectApiName = CONTACT_OBJECT;
    fields = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD];
    recordId;

    handleSuccess(event){
        this.recordId = event.detail.id ;

        const event1 = new ShowToastEvent({
            title: 'Record Created',
            message: 'Contact Record created for id ' +recordId,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event1);
    }


}