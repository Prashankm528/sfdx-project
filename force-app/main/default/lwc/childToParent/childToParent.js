import { api, LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import getContactList from '@salesforce/apex/ContactController.getContactList';
export default class ChildToParent extends LightningElement {
    contacts;
    error;
    @wire(getContactList) 
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            alert(JSON.stringify( this.contacts));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
    
    @wire(getListUi, {
        objectApiName: CONTACT_OBJECT,
        listViewApiName: 'Test',
        sortBy: NAME_FIELD,
        pageSize: 10
    })
    listView;

    callParent(event){
        alert(JSON.stringify(this.listView.data.records.records));
        console.log(this.listView);
        event.preventDefault();
        alert(event.target.dataset.recordid );
        const contactId = event.target.dataset.recordid ;
       

       this.dispatchEvent(new CustomEvent('selected', {detail : contactId})) ;

    }

    @api
    openPopUp(name){
        alert('You are in child' + name);
    }

    get contacts1() {
        return this.listView.data.records.records;
    }
}
