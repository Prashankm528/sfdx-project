import { LightningElement, api } from 'lwc';

export default class Istcp_event extends LightningElement {
    @api name;
    @api dateTime;
    @api fieldLabel1;
    @api fieldLabel2;
    @api fieldLabel3;
    @api fieldValue1;
    @api fieldValue2;
    @api fieldValue3;
}