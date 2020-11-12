import { LightningElement, track, api } from 'lwc';
import getDelieveryPointbylocations from '@salesforce/apex/AITM_AddTenderPackage.getDelieveryPointbylocations';
export default class AITM_ModalPopup extends LightningElement {
    @track isModalOpen = false;
    delieveryPointList;
    locationLineItemId;
    error;
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
        this.deliveryPointId = event.target.dataset.id;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        let params = {"points" : this.deliveryPointId, "lineItemId": locationLineItemId}
        this.dispatchEvent(new CustomEvent('updateDeliveryPoint', {detail:params}));   
        this.isModalOpen = false;
    }
}