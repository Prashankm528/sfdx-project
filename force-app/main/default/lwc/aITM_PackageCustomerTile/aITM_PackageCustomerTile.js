import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getListOfCurrency from '@salesforce/apex/AITM_AddTenderPackage.getListOfCurrency';
import getListOfUOMoptions from '@salesforce/apex/AITM_AddTenderPackage.getListOfUOMoptions';
import updateLocationRecord from '@salesforce/apex/AITM_AddTenderPackage.updateRecord';
import getListOfLineItemsOnStatusChange from '@salesforce/apex/AITM_AddTenderPackage.getListOfLineItemsOnStatusChange';
//import deletePackageCustomers from '@salesforce/apex/AITM_AddTenderPackage.deletePackageCustomers';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LINEITEM_OBJECT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c';
import ID_FIELD from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.Id';
import INTERNAL_NOTES from '@salesforce/schema/AITM_Tender_Location__c.AITM_Internal_Notes_For_Package_Location__c';
import LOCATIONID_FIELD from '@salesforce/schema/AITM_Tender_Location__c.Id';
import CUSTOMER_NAME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Account__c';
import START_DATE from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Start_Date__c';
import END_DATE from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_End_Date__c';
import DELIVERY_POINT from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Location_Delivery_Point__c';
import VOLUME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Requested_Volume_USG__c';
import OFFERED_VOLUME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Offered_Volume__c';
import PERCENTAGE_VOLUME from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Percentage_Volume_Offered__c';
import PRICING_BASIS from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Pricing_Basis__c';
import OFFRED_DIFFERENTIAL from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Package_Offered_Differential__c';
import UNIT_MEASURE from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Unit_Of_Measure__c';
import CURRENCY from '@salesforce/schema/AITM_Tender_Location_Line_Item__c.AITM_Currency__c';

let globalmySet = new Set(); 
let globalLocationSet = new Set(); 
let mapOfUpdatedLineitems =  new Map();
let mapOfUpdatedLocations =  new Map();
let setOfUpdateLocationId = new Set();

export default class AITM_PackageCustomerTile extends NavigationMixin(LightningElement) {
    @api locationLineItems ;
    @api locationStatuses;
    
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
    uomOptions;
    statusReadOnly = true;
    LineItemsId;
    isLoading = false;
    LineItemsOnStatusChange;
    statusToUpdate;
    error;
    locationId;
    locationIndextoUpdate;
    changedInternalNotes;
    tenderLocationId;
    locationItemsOnLocation;
    AllLocations;
    locationBycountry;
    locationByManager;
    allCustomers;
    
    
    
    
   
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
//get picklist of measure
  @wire(getListOfUOMoptions)
    uoMeasureTypes({ error, data }) {
    if (data) {
        console.log('currency data is ' + data);
     this.uomOptions = data.map(type => {
          return {label: type, value: type}
      });
       
    } else if (error) {
        console.log('error is ' + error);
    }
  }

  @api
  searchCustomer(searchvalue){
   // this.searchValue = event.target.value;

   if(this.allCustomers){
    this.locationLineItems = this.allCustomers;
   }
    
    this.locationBySearch = this.locationLineItems.filter(progress=>   
        progress.locationName.toLowerCase().includes(searchvalue.toLowerCase()));
        this.allCustomers =  this.locationLineItems;
        this.locationLineItems = this.locationBySearch;
  }


  @api
  handleCustomerFilter(selectedValue, managerSet , countrySet){
      
      let params = {"selectedValue" : selectedValue, "managerSet":managerSet, "countrySet":countrySet}

    this.dispatchEvent(new CustomEvent('selected', {bubbles: true, composed: true, detail:params})); 
    

  /*  else if(managerSet.has(selectedValue)){
        this.locationByManager = this.locationLineItems.filter(progress=>   
        progress.AITM_Location_Manager__r.Name == selectedValue);
        this.locationLineItems = this.locationByManager;   
    } */
  }

    editRecord(event){
        this.standAloneLocationId = event.target.dataset.id; //location id
        let locationLineItemId = event.target.dataset.recordId //selected lineitem iD
        this.locationItemsOnLocation = event.target.dataset.value; //getting all location to check
        console.log('line item iD is' + locationLineItemId);
        console.log('Location Id is ' +this.standAloneLocationId);
        this.template.querySelector('c-a-i-t-m_-modal-popup').openModal(this.standAloneLocationId, locationLineItemId);
    }
    editPricingBasis(event){
        let locationLineItemId = event.target.dataset.recordId;
        console.log('location id for pricing basis' +locationLineItemId);
        this.template.querySelector('c-a-i-t-m_-pricing-basis-modal').openModal(locationLineItemId);
    }

    updatePricingBasis(event){
        
        let locationLineItemId = event.detail.locationLineItemId;
        let pricingBasisName = event.detail.pricingBasisName; 
        let pricingBasisId = event.detail.pricingBasisId; 
        //let errormsg = event.detail.errormsg;
        console.log('locationLineItemId is:' + locationLineItemId);
        console.log('pricingBasisName is:' + pricingBasisName);
        console.log('pricingBasisId is:' + pricingBasisId);
        const fields = {};
        fields[ID_FIELD.fieldApiName] = locationLineItemId;
        fields[PRICING_BASIS.fieldApiName] = pricingBasisId;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.isLoading = false; 
            this.changedPricingBasis(locationLineItemId, pricingBasisName , pricingBasisId);
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

       
        //this.updateCustomerRecord(recordInput);
      //  this.changedPricingBasis(locationLineItemId, pricingBasisName , pricingBasisId);
       // this.ShowToastNotification('Delivery Point updated',  'Success', 'success');
        
    }

    changedPricingBasis(lineItemId, pricingBasisName , pricingBasisId){
        console.log('lin eitem id is '+ lineItemId);
       // console.log('delivery Name id is '+ deliveryPointName);
       // let locationId = this.template.querySelector(`[id="${lineItemId}"]`).value;
        let locationId1 = this.template.querySelector(`[data-basis="${lineItemId}"]`);
        console.log('Id are ' + locationId1.value );
        //main line 
        this.template.querySelector(`[data-basis="${lineItemId}"]`).value = pricingBasisName;  
        let locationId2 = this.template.querySelector(`[data-basis="${lineItemId}"]`);
        console.log('Id are new  ' + locationId2.value );
    }
    

    handleChange(event){
        this.locationIndextoUpdate = event.target.dataset.index;
        this.locationId = event.target.dataset.value; // id of locqation
        console.log('Location Id is ' +this.locationId); 
        this.statusToUpdate = event.target.value;
        console.log('New status is' + this.statusToUpdate);
        this.getLineItemsOnStatusChange(this.locationId);
        
    }

    getLineItemsOnStatusChange(locationId){
        console.log('inside apex call ' + locationId);
        getListOfLineItemsOnStatusChange({tenderLocationId: locationId})
        .then(result=>{
            this.LineItemsOnStatusChange = result;
            this.isAllMandatoryInformationProvided(this.LineItemsOnStatusChange);
            console.log('LineItemsOnStatusChangeSIZE::' + this.LineItemsOnStatusChange.length);
          })
          .catch(error=>{
            this.LineItemsOnStatusChange = Undefined;
            this.error= error;
          })
    }

    isAllMandatoryInformationProvided(lineItems){
        var result = true;
        var lineItemsErrors = [];
        let isPackageCustomer = false;
        
        for(var i=0; i<lineItems.length; i++) {
            if(lineItems[i].AITM_Tender_Package__c != null){
               
                if(lineItems[i].AITM_Tender_Package__c != null && lineItems[i].AITM_Package_Offered_Differential__c == null ) {
                    isPackageCustomer = true;
                    lineItemsErrors.push('Offered Package Differential');
                    result = false;
                }
                if(lineItems[i].AITM_Pricing_Basis__c == null) {
                    isPackageCustomer = true;
                    lineItemsErrors.push('pricing basis');
                    result = false;
                }
                if(lineItems[i].AITM_Pricing_Basis__c != null && lineItems[i].AITM_Pricing_Basis__r.AITM_Type__c =='C' && lineItems[i].AITM_Current_Value__c == null){
                    isPackageCustomer = true;
                    lineItemsErrors.push('Current Value');
                    result = false;
                }
                if(lineItems[i].AITM_Pricing_Basis__c != null && lineItems[i].AITM_Pricing_Basis__r.AITM_Type__c =='D' && lineItems[i].AITM_Offered_Differential__c == null){
                    isPackageCustomer = true;
                    lineItemsErrors.push('Offered Differential');
                    result = false;
                }
                if(lineItems[i].AITM_Location_Delivery_Point__c == null) {
                    isPackageCustomer = true;
                    lineItemsErrors.push('delivery point');
                    result = false;
                }
                if(lineItems[i].AITM_Currency__c == null) {
                    isPackageCustomer = true;
                    lineItemsErrors.push('currency');
                    result = false;
                }
                if(lineItems[i].AITM_Unit_Of_Measure__c == null) {
                    isPackageCustomer = true;
                    lineItemsErrors.push('unit of measure');
                    result = false;
                }
            }
        }  
            //standalone
            if(!isPackageCustomer){
                console.log('log 1' +isPackageCustomer);
                for(var i=0; i<lineItems.length; i++) {
                    console.log('log 2' +lineItems[i].AITM_Tender_Package__c);
                    if(lineItems[i].AITM_Tender_Package__c == null){
                      
                       /* if(lineItems[i].AITM_Package_Offered_Differential__c == null ) {
                            lineItemsErrors.push('Offered Package Differential');
                            result = false;
                        }*/
                        if(lineItems[i].AITM_Pricing_Basis__c == null) {
                        lineItemsErrors.push('pricing basis');
                        result = false;
                        }
                        if(lineItems[i].AITM_Pricing_Basis__c != null && lineItems[i].AITM_Pricing_Basis__r.AITM_Type__c =='C' && lineItems[i].AITM_Current_Value__c == null){
                        lineItemsErrors.push('Current Value');
                        result = false;
                        }
                        if(lineItems[i].AITM_Pricing_Basis__c != null && lineItems[i].AITM_Pricing_Basis__r.AITM_Type__c =='D' && lineItems[i].AITM_Offered_Differential__c == null){
                        lineItemsErrors.push('Offered Differential');
                        result = false;
                        }
                        if(lineItems[i].AITM_Location_Delivery_Point__c == null) {
                        lineItemsErrors.push('delivery point');
                        result = false;
                        }
                        if(lineItems[i].AITM_Currency__c == null) {
                        lineItemsErrors.push('currency');
                        result = false;
                        }
                        if(lineItems[i].AITM_Unit_Of_Measure__c == null) {
                        lineItemsErrors.push('unit of measure');
                        result = false;
                        }
                
                    }
                } 
            }
            if (lineItemsErrors.length > 0) {
            lineItemsErrors = lineItemsErrors.filter(function(item, pos, self) {
                return self.indexOf(item) == pos;
            });
            //this.dispatchEvent(new CustomEvent('refresh', {bubbles: true, composed: true})); 
            this.template.querySelector(`[data-index="${this.locationIndextoUpdate}"]`).value = this.oldValue;  
            if(isPackageCustomer){
                this.ShowToastNotification('error', 'Please fill in field(s): ' + lineItemsErrors.join(', ') + ' for all Package Tender Location Items', 'error');
            }
            else{
                this.ShowToastNotification('error', 'Please fill in field(s): ' + lineItemsErrors.join(', ') + ' for all Standalone Tender Location Items ', 'error');
            }
            }
            else{
                this.updateLocationRecord('AITM_Tender_Location__c', this.locationId, 'AITM_Status__c', this.statusToUpdate, lineItems);
            }
    
    }

    updateLocationRecord(objectName, recordId, fieldName, value,lineItems ){
        updateLocationRecord({objectName:objectName,recordId: recordId, fieldName: fieldName, value: value, lineItems:lineItems})
        .then(result=>{
            this.ShowToastNotification('Success', 'Tender Location is updated to '+ value  , 'success');
          })
          .catch(error=>{
            
          })

    }

    ShowToastNotification(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
        this.isLoading = false;
        if(!this.packName){
            this.disableCreate =false;
        }
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
    

    // getting the id of location when clicked on location name
    getLocationId(event){
       // let targetId = event.target.dataset.targetId;//key
       let targetId = event.target.dataset.value;
       console.log('Map key is' +targetId)
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
        
        //this.isAllMandatoryInformationProvidedForLineItem(this.locationItemsOnLocation);
        //let delieveryPointId = event.detail.points;
       
        let locationLineItemId = event.detail.lineItemId;
        let deliveryPointName = event.detail.name; 
        let errormsg = event.detail.errormsg;
        console.log('error msg is:' + errormsg);
        if(errormsg){
           
            this.ShowToastNotification('Error updating delivery Point',  errormsg, 'error');
        }
        else{
            this.changedDeliveryPoint(locationLineItemId, deliveryPointName);
            this.ShowToastNotification('Delivery Point updated',  'Success', 'success');
        }
        

       /* console.log('deelievery point id is  :' + delieveryPointId) 
        const fields = {};
        fields[ID_FIELD.fieldApiName] = locationLineItemId;
        fields[DELIVERY_POINT.fieldApiName] = delieveryPointId;
        const recordInput = { fields };
        this.changedDeliveryPoint(locationLineItemId, deliveryPointName);
        this.updateCustomerRecord(recordInput);*/
        //this.changedDeliveryPoint(locationLineItemId, deliveryPointName);
         

    }

    

    changedDeliveryPoint(lineItemId, deliveryPointName){
        console.log('lin eitem id is '+ lineItemId);
        console.log('delivery Name id is '+ deliveryPointName);
       // let locationId = this.template.querySelector(`[id="${lineItemId}"]`).value;
        let locationId1 = this.template.querySelector(`[data-name="${lineItemId}"]`);
        console.log('Id are ' + locationId1.value );
        this.template.querySelector(`[data-name="${lineItemId}"]`).value = deliveryPointName;  
        let locationId2 = this.template.querySelector(`[data-name="${lineItemId}"]`);
        console.log('Id are new  ' + locationId2.value );
    }

    //Select All checkbox
    selectcheckbox(event){
        
        //alert('inside all checkboxes');
        
        let targetId = event.target.dataset.targetId;//key
        
        
        //globalLocationSet
        console.log('Selected Checkbox' + targetId);

        let target = this.template.querySelectorAll(`[data-id="${targetId}"]`);
        if(event.target.checked){
        let targetId = event.target.dataset.targetId;
        globalLocationSet.add(targetId);
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
            let targetId = event.target.dataset.targetId;
            globalLocationSet.delete(targetId);
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
                            globalLocationSet.add(individualTargetId);
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
                globalLocationSet.delete(individualTargetId);
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

       // console.log(this.locationLineItems[0].locationLineItemsList);
        
        let listoflineItemsToDelete = [];
        let listofLocationsToDelete = [];
        for (var item of globalmySet.values()){
            listoflineItemsToDelete.push(item);
                   
        }
        for (var item of globalLocationSet.values()){
            listofLocationsToDelete.push(item);
               
        }

       

       let params = {"listoflineItemsToDelete" : listoflineItemsToDelete, "listofLocationsToDelete":listofLocationsToDelete}

       this.dispatchEvent(new CustomEvent('refresh', {bubbles: true, composed: true, detail:params})); 
      /*  deletePackageCustomers({listOfLineItemsIds:listoflineItemsToDelete})
        .then(result=>{
            console.log('Records delete');
            this.dispatchEvent(new CustomEvent('refresh', {bubbles: true, composed: true, detail:params})); 
        })
        .catch(error=>{

        })*/

      
        for (var item of globalLocationSet.values()){
            var y= y + item + ' '; 
               
        }

       
        console.log('Final individual  line items in global event set are'+ listoflineItemsToDelete);
        console.log('Final individual  location items in global event set are'+ listofLocationsToDelete);
        console.log('Final individual  value in location global set are'+ y);
    }
    @api
    cloneLineItems(){
        let listoflineItemsToClone = [];
        for (var item of globalmySet.values()){
            listoflineItemsToClone.push(item);
                   
        }
        if(globalmySet.size>0){
            globalmySet.clear();
        }
       
        let params = {"listoflineItemsToClone" : listoflineItemsToClone}

        this.dispatchEvent(new CustomEvent('clone', {bubbles: true, composed: true, detail:params})); 
        
    }

    handleInternalNotes(event){ 
        this.changedInternalNotes = event.target.value;
        console.log(this.changedInternalNotes);
        if(this.oldValue !=  this.changedInternalNotes ){
            //this.isLoading = true; 
            this.tenderLocationId = event.target.dataset.value;
            if(mapOfUpdatedLocations.has(this.tenderLocationId)){
                let valtoUpdate = mapOfUpdatedLocations.get(this.tenderLocationId);
                valtoUpdate.locationId = this.tenderLocationId;
                valtoUpdate.internalNotes = this.changedInternalNotes;
                mapOfUpdatedLocations.set(this.tenderLocationId,valtoUpdate);
            }
            else{
                mapOfUpdatedLocations.set(this.tenderLocationId,{internalNotes:this.changedInternalNotes, locationId: this.tenderLocationId})
            }
            
            const fields = {};
            fields[LOCATIONID_FIELD.fieldApiName] = this.tenderLocationId;
            fields[INTERNAL_NOTES.fieldApiName] = this.changedInternalNotes;
            const recordInput = { fields };
            //this.updateCustomerRecord(recordInput);
        }
    }

    getCurrencyValue(event){
        this.packageContribution = event.target.value;
        console.log(this.packageContribution);
        if(this.oldValue !=  this.packageContribution ){
            //this.isLoading = true; 
            this.tenderLocationId = event.target.dataset.value;
            if(mapOfUpdatedLocations.has(this.tenderLocationId)){
                let valtoUpdate = mapOfUpdatedLocations.get(this.tenderLocationId);
                valtoUpdate.locationId = this.tenderLocationId;
                valtoUpdate.packageContribution = this.packageContribution;
                mapOfUpdatedLocations.set(this.tenderLocationId,valtoUpdate);
            }
            else{
                mapOfUpdatedLocations.set(this.tenderLocationId,{packageContribution:this.packageContribution, locationId: this.tenderLocationId})
            }
    }
}
    
  
    handleStartDate(event){
        this.changedStartDate = event.target.value;
        console.log(this.changedStartDate);
        if(this.oldValue !=  this.changedStartDate ){
            //this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.startDate = this.changedStartDate;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{startDate:this.changedStartDate, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[START_DATE.fieldApiName] = this.changedStartDate;
            const recordInput = { fields };
           // this.updateCustomerRecord(recordInput);
            }
    }

    handleEndDate(event){
        this.changedEndDate = event.target.value;
        console.log(this.changedEndDate);
        if(this.oldValue != this.changedEndDate ){
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.endDate = this.changedEndDate;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{endDate:this.changedEndDate, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[END_DATE.fieldApiName] = this.changedEndDate;
            const recordInput = { fields };
          //  this.updateCustomerRecord(recordInput);
        }
    }

    handleVolume(event){
       
        this.changedVolume = event.target.value;
        console.log(this.changedVolume);
        if(this.oldValue != this.changedVolume ){
           // this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
           // mapOfUpdatedLineitems.set(this.LineItemsId,{AITM_Volume__c:this.changedVolume})
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.requestedVolumeUom = this.changedVolume;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{requestedVolumeUom:this.changedVolume, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[VOLUME.fieldApiName] = this.changedVolume; 
            const recordInput = { fields };
            for (const [key, value] of mapOfUpdatedLineitems.entries()) {
                console.log( 'updated values are 1' + key, value);
              }
           // this.updateCustomerRecord(recordInput);
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
        if(this.oldValue != this.changedOffered){
            //this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.offeredVolumeUom =  this.changedOffered;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{offeredVolumeUom:this.changedOffered,lineItemId: this.LineItemsId})
            }
           
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[OFFERED_VOLUME.fieldApiName] = this.changedOffered;
            const recordInput = { fields };
            for (const [key, value] of mapOfUpdatedLineitems.entries()) {
                console.log( 'updated values are 2' + key, value);
              }
           // this.updateCustomerRecord(recordInput);
        }
    }

    handlePercentage(event){    
        this.changedPercentage = event.target.value;
        console.log(this.changedPercentage);
        if(this.oldValue != this.changedPercentage ){
            
            
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.changedPercentage = this.changedPercentage;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{changedPercentage:this.changedPercentage, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[PERCENTAGE_VOLUME.fieldApiName] = this.changedPercentage;
            const recordInput = { fields };
           // this.updateCustomerRecord(recordInput);
        }
    } 

   /* handlePricing(event){
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
    } */
    handleDiffPackage(event){   
        this.changedDiffPackage = event.target.value;
        console.log(this.changedDiffPackage);
        console.log('data id is ' + event.target.dataset.id);
        if(this.oldValue != this.changedDiffPackage ){
           // this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.differentialPackage = this.changedDiffPackage;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{differentialPackage:this.changedDiffPackage, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[OFFRED_DIFFERENTIAL.fieldApiName] = this.changedDiffPackage;
            const recordInput = { fields };
           // this.updateCustomerRecord(recordInput);
        }
    }

    handleMeasure(event){
        this.changedMeasure = event.target.value;
        console.log(this.changedMeasure);
        if(this.oldValue != this.changedMeasure ){
           // this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.unitOfMeasure = this.changedMeasure;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{unitOfMeasure:this.changedMeasure, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[UNIT_MEASURE.fieldApiName] = this.changedMeasure;
            const recordInput = { fields };
           // this.updateCustomerRecord(recordInput);
        }
    }

    handleCurrency(event){
        
        this.changedCurrency = event.detail.value;
        console.log(this.changedCurrency);
        if(this.oldValue != this.changedCurrency ){
            //this.isLoading = true; 
            this.LineItemsId = event.target.dataset.id;
            if(mapOfUpdatedLineitems.has(this.LineItemsId)){
                let valtoUpdate = mapOfUpdatedLineitems.get(this.LineItemsId);
                valtoUpdate.lineItemId = this.LineItemsId;
                valtoUpdate.updatedcurrency = this.changedCurrency;
                mapOfUpdatedLineitems.set(this.LineItemsId,valtoUpdate);
            }
            else{
                mapOfUpdatedLineitems.set(this.LineItemsId,{updatedcurrency:this.changedCurrency, lineItemId: this.LineItemsId})
            }
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.LineItemsId;
            fields[CURRENCY.fieldApiName] = this.changedCurrency;
            const recordInput = { fields };
          //  this.updateCustomerRecord(recordInput);
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
             //   this.dispatchEvent(new CustomEvent('refresh', {bubbles: true, composed: true})); 
    }
    @api
    saveLineItems(){
        
        let listofUpdatedItems = [];
        let locationToUpdate = [];
        let listOfId = [];
        
       /* for (const [key, value] of mapOfUpdatedLineitems.entries()) {
            console.log( 'updated values are' + key, value);
          }*/
        locationToUpdate = Array.from(mapOfUpdatedLocations.values());
         // console.log(Array.from(mapOfUpdatedLineitems));
         listOfId = Array.from(mapOfUpdatedLineitems.keys());
         console.log('id are' +  JSON.stringify(locationToUpdate));
         listofUpdatedItems = Array.from(mapOfUpdatedLineitems.values());
         console.log('listofUpdatedItems are' + JSON.stringify(listofUpdatedItems));
         let params = {"listoflId" : listOfId, "listoflineItemtoUpdate":listofUpdatedItems, "locationToUpdate":locationToUpdate}

       this.dispatchEvent(new CustomEvent('save', {bubbles: true, composed: true, detail:params})); 

      /*  console.log('updated values are' +  mapOfUpdatedLineitems.values());
        for(let i=0 ; i< mapOfUpdatedLineitems.values().length; i++){
            var xyz = mapOfUpdatedLineitems.values();
            listofUpdatedItems.push(xyz);
        }
        console.log('list is ' +listofUpdatedItems); */
       /* let listofupdatelineItems = []
        for(let j=0;j< this.locationLineItems.length; j++){
            for(let k=0;k< this.locationLineItems[j].locationLineItemsList.length; k++){
                listofupdatelineItems.push(this.mapkeyValueStore[j].locationLineItemsList[k]);
                console.log('list after change' +this.mapkeyValueStore[j].locationLineItemsList[k].AITM_Percentage_Volume_Offered__c);
       
            }
        } */
    }


}