import { LightningElement , api } from 'lwc';

export default class Foc extends LightningElement {
    @api recordId;

    nextHandler(event){
        this.template.querySelector('lightning-tabset').activeTabValue = 'two';
    }
}