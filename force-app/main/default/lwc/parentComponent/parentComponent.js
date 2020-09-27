import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {

    ContactId;
    
    callDetails(event){
        alert('inside parent');
       
        this.ContactId = event.detail;
        
        alert(this.ContactId);
       
    }

    childmethod(){
        this.template.querySelector("c-child-to-parent").openPopUp('Prashank');
    }
}