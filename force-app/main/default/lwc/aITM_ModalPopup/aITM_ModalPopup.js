import { LightningElement, track, api } from 'lwc';
import getDelieveryPointbylocations from '@salesforce/apex/AITM_AddTenderPackage.getDelieveryPointbylocations';
import updateDeliveryRecords from '@salesforce/apex/AITM_AddTenderPackage.updateDeliveryRecords';
export default class AITM_ModalPopup extends LightningElement {
    @track isModalOpen = false;
    delieveryPointList;
    deliveryPointName;
    locationLineItemId;
    error;
    errorMsg;
    deliveryPointId;
    radioOptions;
    @api
    openModal(locationId, lineItemId) {
        // to open modal set isModalOpen tarck value as true
        this.locationLineItemId =  lineItemId;
        console.log('modal line Item Id' +this.locationLineItemId);
        //alert('Prashank');
        getDelieveryPointbylocations({locationId: locationId})
        .then(result=>{
            this.delieveryPointList = result;
            this.radioOptions = this.delieveryPointList.map(type=>{
                return {label: "", value: type.Id}
            })
            this.isModalOpen = true;

            console.log('location Line item list is' +  this.delieveryPointList);
          })
          .catch(error=>{
           
            console.log(error);
            this.error= error;
          })
        
    }

    getDelieveryPoint(event){
        this.deliveryPointName = event.target.dataset.targetId;
        this.deliveryPointId = event.target.dataset.id;
       // updateDeliveryRecords({deliveryRecordId:event.target.dataset.id, lineItemId:this.locationLineItemId})
        console.log('IndeliveryPointiddataset' +this.deliveryPointName);
        console.log('IndeliveryPointiddataset' + event.target.dataset.id);
        console.log('locationLineItemsId is' +  this.locationLineItemId);
       
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        this.isModalOpen = false;
       // alert('1');
        updateDeliveryRecords({deliveryRecordId:this.deliveryPointId, lineItemId:this.locationLineItemId})
        .then(result=>{
            //this.errorMsg = result;
            console.log('result is ' +result);
            let params = {"errormsg" : result,  "name" : this.deliveryPointName, "lineItemId": this.locationLineItemId }
        this.dispatchEvent(new CustomEvent('point', {detail:params})); 
          })
          .catch(error=>{
            this.error= error;
          })
       // let params = {"errormsg" : this.errorMsg,  "name" : this.deliveryPointName }
       // this.dispatchEvent(new CustomEvent('point', {detail:params}));   
       
    }
}