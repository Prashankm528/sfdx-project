import { LightningElement, api, wire } from 'lwc';
import getListOfCurrency from '@salesforce/apex/AITM_AddTenderPackage.getListOfCurrency';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LINEITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import ID_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.Id';
import CUSTOMER_NAME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Account__c';
import START_DATE from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Start_Date__c';
import END_DATE from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_End_Date__c';
import DELIVERY_POINT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Location__r.AITM_Delivery_Point__c';
import VOLUME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Volume__c';
import OFFERED_VOLUME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Offered_Volume__c';
import PERCENTAGE_VOLUME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Percentage_Volume_Offered__c';
import PRICING_BASIS from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_DEPE_Pricing_Basis__c';
import OFFRED_DIFFERENTIAL from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Package_Offered_Differential__c';
import PERCENTAGE_OFFERED from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Percentage_Volume_Offered__c';
import UNIT_MEASURE from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Unit_Of_Measure__c';
import CURRENCY from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Currency__c';


let globalmySet = new Set();
export default class AITM_PackageCustomerTile extends NavigationMixin(LightningElement) {
    @api locationLineItems ;
    @api locationStatuses;
    //value = 'Priced'
    selectedid =[]; // multiple selected
    removeId = [];
    standAloneLocationId;
    selecteIdIndividual=[]; // Individual select
    changedAccountName;
    changedDeliveryPoints;
    changedEndDate;
    changedStartDate;
    changedVolume;
    changedOffered;
    changedPercentage;
    changedPricing;
    changedDiffPackage;
    changedMeasure;
    changedCurrency;
    selectedStatus;
    searchOptions;
    statusReadOnly = true;
    LineItemsId;
    isLoading = false;

    get options() {
        return [
            { label: 'Awaiting price', value: 'Awaiting price' },
            { label: 'Priced', value: 'Priced' },
            { label: 'Not Represented', value: 'Not Represented' },
        ];
    }
//getting Picklist of currency
    @wire(getListOfCurrency)
    currencyTypes({ error, data }) {
    if (data) {
        console.log('currency data is ' + data);
     this.searchOptions = data.map(type => {
          return {label: type, value: type}
      });
       
    } else if (error) {
        console.log('error is ' + error);
    }
  }

    editRecord(event){
        this.standAloneLocationId = event.target.dataset.id;
        let locationLineItemId = event.target.dataset.recordId
        console.log('line item iD is' + locationLineItemId);
        console.log('Location Id is ' +this.standAloneLocationId);
        this.template.querySelector('c-a-i-t-m_-modal-popup').openModal(this.standAloneLocationId, locationLineItemId);
    }

    handleChange(event){
        let targetId = event.target.dataset.index;
       // alert(targetId);

        this.selectedStatus = this.template.querySelector(`[data-index="${targetId}"]`).value;
        let status = event.target.value;
       // alert(status);
        this.statusReadOnly = true;
    }

    changeStatus(event){
        let targetId = event.target.dataset.index;
       // alert(targetId);
        let booleanStatus =false;
         this.template.querySelector(`[data-index="${targetId}"]`).name =false;
        //booleanStatus = false;
        this.statusReadOnly = false;
    }

    

    openLineItemRecord(event){
        event.preventDefault();
        let LineItemId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: LineItemId ,
                objectApiName: 'AITM_Tender_Location_Line_Item__c',
                actionName: 'view'
            },
        });

    }
    
    /*renderedCallback(){
        console.log('location status in child' + JSON.stringify(this.locationStatuses));
    } */

    // getting the id of location when clicked on location name
    getLocationId(event){
       // let targetId = event.target.dataset.targetId;//key
       let targetId = event.target.dataset.value;
       // console.log('Map key is' +targetId)
       // let target = this.template.querySelector(`[data-id="${targetId}"]`).value;
       // console.log('Id is' + target );
        
    }

    openCustomerRecord(event){
        event.preventDefault();
        let CustomerId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: CustomerId ,
                objectApiName: 'AAITM_Account__c',
                actionName: 'view'
            },
        });
    }

    updatePoint(event){
        let delieveryPointId = event.detail.points;
        let locationLineItemId = event.detail.lineItemId;

        const fields = {};
        fields[ID_FIELD.fieldApiName] = locationLineItemId;
        fields[DELIVERY_POINT.fieldApiName] = delieveryPointId;
        const recordInput = { fields };
        this.updateCustomerRecord(recordInput);

    }

    //Select All checkbox
    selectcheckbox(event){
        
        //alert('inside all checkboxes');
        
        let targetId = event.target.dataset.targetId;//key
        console.log('Selected Checkbox' + targetId);
        let target = this.template.querySelectorAll(`[data-id="${targetId}"]`);
        if(event.target.checked){
        let targetId = event.target.dataset.targetId;
        console.log('Selected Checkbox' + targetId);
        

            for( let i=0; i<target.length; i++) {
                target[i].checked = event.target.checked;
                globalmySet.add(target[i].dataset.targetId);
                
            }
            for (var item of globalmySet.values()){
                 var val= val + item + ' '; 
                    console.log('set value is' + val);
            }
                    
        }
        else{
           
            for( let i=0; i<target.length; i++) {
                target[i].checked = false;
                globalmySet.delete(target[i].dataset.targetId);
               
            }
        }
           
            for (var item of globalmySet.values()){
                var val= val + item + ' '; 
                    console.log('set value adding and removal is' + val);
            }
           
        }


        
    
    //select Individual CheckBox
    handleclickCheckBox(event){ 
       
        let selectChecboxbasedonKey = [];
        if(event.target.checked){
            let individualTargetId = event.target.dataset.id; // location  id
            console.log('individualTargetId is' + individualTargetId);
            let individualRecordId = event.target.dataset.targetId; //value id
            console.log('individualRecordId is' + individualRecordId);
           
          //getting all checkboxes related to that location id
                let checkboxes = this.template.querySelectorAll(`[data-id="${individualTargetId}"]`); 
                console.log('individualTargetId is' + checkboxes.length);
                for( let i=0; i<checkboxes.length; i++) { 
                   
                if(checkboxes[i].checked === true){
                  
                    selectChecboxbasedonKey.push(checkboxes[i]);
                        if(selectChecboxbasedonKey.length == checkboxes.length ){
                            let checkboxes1 = this.template.querySelector(`[data-target-id="${individualTargetId}"]`);//key
                            checkboxes1.checked = true;
                        }
                    }
                else{
                    let checkboxes1 = this.template.querySelector(`[data-target-id="${individualTargetId}"]`);
                    checkboxes1.checked = false ;
                    }
                }
               
                globalmySet.add(individualRecordId);
                for (var item of globalmySet.values()){
                    var val= val + item + ' '; 
                        console.log('total  value in set are' + val);
                }
        }


            else{
                let individualTargetId = event.target.dataset.id; 
                let checkboxes1 = this.template.querySelector(`[data-target-id="${individualTargetId}"]`);
                checkboxes1.checked = false ;
                let individualRecordId = event.target.dataset.targetId;
                globalmySet.delete(individualRecordId);
               
                    
    
                  for (var item of globalmySet.values()){
                    var val= val + item + ' '; 
                        console.log('Final individual  value in set are'+ val);
                }
            }
    }
    @api
    deleteCustomerLocation(){

        for (var item of globalmySet.values()){
            var x= x + item + ' '; 
                console.log('Final individual  value in global set are'+ x);
        }
    }
    /*@api
    checkedCustomerScreen(){
        alert('inside grandchild');
        this.dispatchEvent(new CustomEvent('back', {bubbles: true, composed: true, detail:globalmySet}));   
        
    }*/


  /*  handleAccountName(event){
       
        this.changedAccountName = event.target.value;
        if(this.oldValue != this.changedAccountName ){
            this.isLoading = true; 
            //this.LineItemsId = event.target.dataset.id;
            let customerId =  event.target.dataset.recordId;
            console.log(this.changedAccountName);
            const fields = {};
            fields[ID_FIELD.fieldApiName] = customerId;
            fields[CUSTOMER_NAME.fieldApiName] = this.changedAccountName;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    } */

    handleDeliveryPoints(event){
       
        this.isLoading = true; 
        this.changedDeliveryPoints = event.target.value;
        console.log(this.changedDeliveryPoints);
        if(this.oldValue != this.changedDeliveryPoints ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[DELIVERY_POINT.fieldApiName] = this.changedDeliveryPoints;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
            
    }
    handleStartDate(event){
        
        this.changedStartDate = event.target.value;
        console.log(this.changedStartDate);
        if(this.oldValue != this.changedDeliveryPoints ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[START_DATE.fieldApiName] = this.changedStartDate;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
            }
    }

    handleEndDate(event){
        this.changedEndDate = event.target.value;
        console.log(this.changedEndDate);
        if(this.oldValue != this.changedDeliveryPoints ){
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[END_DATE.fieldApiName] = this.changedEndDate;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }
    handleVolume(event){
        
       
        this.changedVolume = event.target.value;
        console.log(this.changedVolume);
        if(this.oldValue != this.changedVolume ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[VOLUME.fieldApiName] = this.changedVolume;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }

    oldvalue(event){
        console.log('test' +event.oldValue);
        console.log('old value is ' + event.target.value);
        this.oldValue = event.target.value;
    }

    handleOffered(event){
        
        this.changedOffered = event.target.value;
        console.log(this.changedOffered);
        if(this.oldValue != this.changedOffered ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[OFFERED_VOLUME.fieldApiName] = this.changedOffered;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }

    handlePercentage(event){
        
        this.changedPercentage = event.target.value;
        console.log(this.changedPercentage);
        if(this.oldValue != this.changedPercentage ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[PERCENTAGE_VOLUME.fieldApiName] = this.changedPercentage;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }

    handlePricing(event){
        this.isLoading = true; 
        this.changedPricing = event.target.value;
        console.log(this.changedPricing);
        if(this.oldValue != this.changedPricing ){
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[PRICING_BASIS.fieldApiName] = this.changedPricing;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }
    handleDiffPackage(event){
       
        this.changedDiffPackage = event.target.value;
        console.log(this.changedDiffPackage);
        console.log('data id is ' + event.target.dataset.id);
        if(this.oldValue != this.changedDiffPackage ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[OFFRED_DIFFERENTIAL.fieldApiName] = this.changedDiffPackage;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }

    handleMeasure(event){
       
        this.changedMeasure = event.target.value;
        console.log(this.changedMeasure);
        if(this.oldValue != this.changedMeasure ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[UNIT_MEASURE.fieldApiName] = this.changedMeasure;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }

    handleCurrency(event){
        
        this.changedCurrency = event.detail.value;
        console.log(this.changedCurrency);
        if(this.oldValue != this.changedCurrency ){
            this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[CURRENCY.fieldApiName] = this.changedCurrency;
            const recordInput = { fields };
            this.updateCustomerRecord(recordInput);
        }
    }

    updateCustomerRecord(recordInput){
        updateRecord(recordInput)
                .then(() => {
                    this.isLoading = false; 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Customer updated',
                            variant: 'success'
                        })
                    );
                    
                   
                })
                .catch(error => {
                    this.isLoading = false; 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
    }
}
