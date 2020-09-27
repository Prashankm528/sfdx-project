import { LightningElement , api, wire, track} from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import Manager_field from '@salesforce/schema/Employee_Detail__c.IsManager__c';
const fields = [Manager_field];
export default class ERPComponent extends LightningElement {
    
    @api recordId;
   
    @wire(getRecord, { recordId: '$recordId', fields })
    empManager;

    get areDetailsVisible(){
        return  getFieldValue(this.empManager.data, Manager_field);
    }
  

}

