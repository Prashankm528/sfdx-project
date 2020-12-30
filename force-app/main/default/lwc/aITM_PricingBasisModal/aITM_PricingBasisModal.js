import { LightningElement,track,api } from 'lwc';

export default class AITM_PricingBasisModal extends LightningElement {
    @track isModalOpen = false;
    locationlineItemId;

    @api
    openModal(locationLineItemId) {
        // to open modal set isModalOpen tarck value as true
        this.locationLineItemId = locationLineItemId;
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        alert('submit');
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.template.querySelector('c-a-i-t-m_-lwc-lookup').callparent(this.locationLineItemId);
        this.isModalOpen = false;
    }
}