import { LightningElement, track, wire, api } from "lwc";  
import findRecords from "@salesforce/apex/AITM_AddTenderPackage.findRecords";
export default class AITM_LwcLookup extends LightningElement {

  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @api tender;
  @track message;  
    
  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  

  get account(){
    if(this.objectApiName == 'AITM_Tender_Account__c'){
        return true;
    }
  }
  
  get pricing(){
    if(this.objectApiName == 'AITM_Pricing_Basis__c'){
       return true;
    }
  }
    
  onRecordSelection(event) {  
   
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name;  
   console.log('selected value is' +  this.selectedValue);
   console.log('selected record is' +  this.selectedRecordId);
   if(this.objectApiName == "AITM_Tender_Account__c"){
      
      let params = {"selectedCustomer": this.selectedValue, "selectedAccount":this.selectedRecordId}
      this.dispatchEvent(new CustomEvent('select', {detail:params}));  
   }
   this.searchKey = "";  
  // this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
   
  removeRecordOnLookup(event) {  
    alert('test');
   this.searchKey = "";  
   this.selectedValue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   if(this.objectApiName == "AITM_Tender_Account__c"){
    this.dispatchEvent(new CustomEvent('remove'));  
   }
   //this.onSeletedRecordUpdate();  
 }  

 getLookupResult() {  
    findRecords({ searchKeyWord: this.searchKey, ObjectName : this.objectApiName, tender: this.tender })  
     .then((result) => {  
      if (result.length===0) {  
        
        this.recordsList = [];  
        this.message = "No Records Found";  
       } else {  
         
        this.recordsList = result;  
        console.log('value is ' +JSON.stringify(result));
        this.message = "";  
       }  
       this.error = undefined;  
     })  
     .catch((error) => {  
      
      this.error = error;  
      console.log('error is ' +JSON.stringify(error));
      this.recordsList = undefined;  
     });  
   }  
    
   @api
   callparent(locationLineItemId){  
        alert('insideSelected')
        let params = {"pricingBasisId" : this.selectedRecordId, "pricingBasisName":this.selectedValue, "locationLineItemId": locationLineItemId }
        this.dispatchEvent(new CustomEvent('pricing', {bubbles: true, composed: true, detail:params}));  
   }  
}