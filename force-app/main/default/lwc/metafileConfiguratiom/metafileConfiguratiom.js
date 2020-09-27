import { LightningElement,api } from 'lwc';

export default class MetafileConfiguratiom extends LightningElement {

    @api message;
    @api width;
    @api height;
    @api Sobject

    @api recordId;
    @api objectApiName;
    

    handleSuccess(event){
        this.recordId = event.detail.id;
    }
}