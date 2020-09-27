import { LightningElement, track , api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTimesheetRecord from '@salesforce/apex/ErpClass.getTimeDetails'

export default class TimeCard extends NavigationMixin(LightningElement) {
    @api  emp ;
   
    @track data ;
    
    handleTime(){
        alert(this.emp);
        var compDefinition = {
            componentDef: "c:timeCardDetails",
            attributes: {
                recordId: this.emp
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
   
  
    connectedCallback(){
        this.getHolidays();
    }
    getHolidays(){
        getTimesheetRecord({employeeID : this.emp })
        .then(result=>{
            this.data = result;
            
            
        })
        .catch(error=>{
           
            this.data = undefined;
        })
}
}