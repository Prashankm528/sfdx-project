import { LightningElement, api, wire } from 'lwc';
import getBoats from '@salesforce/apex/BoatDataService.getBoats';
import { publish, MessageContext } from 'lightning/messageService';
import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLS = [
  { label: 'Name', fieldName: 'Name', editable: true },
  { label: 'Length', fieldName: 'Length__c', editable: true },
  { label: 'Price', fieldName: 'Price__c', editable: true },
  { label: 'Description', fieldName: 'Description__c', editable: true },
  
];
const SUCCESS_TITLE = 'Success';
const MESSAGE_SHIP_IT     = 'Ship it!';
const SUCCESS_VARIANT     = 'success';
const ERROR_TITLE   = 'Error';
const ERROR_VARIANT = 'error';
export default class BoatSearchResults extends LightningElement {
    
 
  selectedBoatId;
  columns = [];
  boatTypeId = '';

  columns = COLS;
  
  boats;
  isLoading = false;
  
  // wired message context
  @wire(MessageContext)
  messageContext;
  // wired getBoats method 
 @wire( getBoats ,{boatTypeId : '$boatTypeId'})
 wiredBoats(value) {
  
  this.boats = value;
   if (value.error) { 
  }
  this.isLoading = false;
  this.notifyLoading(this.isLoading);
}

 
  
  // public function that updates the existing boatTypeId property
  // uses notifyLoading
  @api
  searchBoats(boatTypeId) { 
    this.isLoading = true;
    this.notifyLoading(this.isLoading);
      this.boatTypeId = boatTypeId;
     

  }
  
  // this public function must refresh the boats asynchronously
  // uses notifyLoading ,  need to check
  @api 
     async refresh() {
            this.isLoading = true;
            this.notifyLoading(this.isLoading);
             await refreshApex(this.boats)
            .then(() =>{ 
                this.isLoading = false;
                this.notifyLoading(this.isLoading);
            })
            .catch(() => {
                this.isLoading = false;
                this.notifyLoading(this.isLoading);
            });
          }
  
  // this function must update selectedBoatId and call sendMessageService
  updateSelectedTile(event) {
    
    this.selectedBoatId = event.detail.boatId;
    
    this.sendMessageService(this.selectedBoatId);
  }
  
  // Publishes the selected boat Id on the BoatMC.
  sendMessageService(boatId) { 
        const payload = { recordId: boatId };

        publish(this.messageContext, BOATMC, payload);
    // explicitly pass boatId to the parameter recordId
  }
  
  // This method must save the changes in the Boat Editor
  // Show a toast message with the title
  // clear lightning-datatable draft values
  handleSave(event) {
    console.log(event.detail.draftValues);
    const recordInputs = event.detail.draftValues.slice().map(draft => {
        const fields = Object.assign({}, draft);    // Object.assign({},draft) , means clone fields with draft values  
        return { fields };
    });
    console.log('recordInputs', recordInputs);   // Array of Fields with their keys 
    //uiRecordAPi to updateRecord returns Promise, we have multiple Selection Fields so for each selection it returns a promise
    const promises = recordInputs.map(recordInput => updateRecord(recordInput));
    //Promise.all -- take array of promises and return one promise 
    Promise.all(promises).then(records => {
        console.log('success');
        this.dispatchEvent(
            new ShowToastEvent({
                title: SUCCESS_TITLE,
                message: MESSAGE_SHIP_IT,
                variant: SUCCESS_VARIANT
            }));
        // Clear all draft values
        this.draftValues = [];
        // Display fresh data in the datatable
        this.refresh();     //return refreshApex(this.boats);
    }).catch(error => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: ERROR_TITLE,
                message: error,
                variant: ERROR_VARIANT
            }));
    }).finally(() => { });
}

  // Check the current value of isLoading before dispatching the doneloading or loading custom event
  notifyLoading(isLoading) { 
    if(isLoading)
    {
        const clickEvt = new CustomEvent('loading');
        this.dispatchEvent(clickEvt);
    }
    else
    {
        const clickEvt = new CustomEvent('doneloading');
        this.dispatchEvent(clickEvt);
    }
}

}
