import { LightningElement,api } from 'lwc';

export default class MetafileConfiguratiom extends LightningElement {

    @api message;
    @api width;
    @api height;

    @api recordId;
    @api objectApiName;
    

    handleSuccess(event){
        this.recordId = event.detail.id;
    }
}