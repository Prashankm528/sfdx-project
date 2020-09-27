import { LightningElement ,track, api } from 'lwc';
import getData from '@salesforce/apex/getContacts.getContactsList';
import sendCaseId from '@salesforce/apex/getContacts.addCaseToOpportunities';
import { NavigationMixin } from 'lightning/navigation';

export default class CaseswithCheckbox extends NavigationMixin(LightningElement) {
    @api recordId;
    @track allData = [] ;
    selectedValue =  []
    selectedItem = '';
    handleItemClicked(event) {
       
       if(event.target.checked){
       this.selectedItem = event.target.dataset.recordId;
       this.selectedValue.push(this.selectedItem);
        
        alert(this.selectedItem);
        alert(this.selectedValue);
        alert(this.recordId);
       
    }
    else{
        this.selectedItem = event.target.dataset.recordId;
        this.selectedValue.pop(this.selectedItem);
        alert('Prashank' + this.selectedItem);
    }
}
    connectedCallback(){
       // alert(recordId);
        this.getAlldata();
    }

    getAlldata(){
        getData()
            .then(result=>{
                this.allData = result;
                alert('Prashank');
                alert(this.allData);
            })
            .catch(error=>{
                this.allData = undefined;
            })
    }

    handlechangeButton(event){
        sendCaseId(
            {caseId:this.selectedValue,
            AccountId:this.recordId}
            )
            .then(() => {
                
                if(this.isOpenInConsole) {
                    this.dispatchEvent(new CustomEvent('doclose', {
                        detail: {},
                        bubbles: true,
                        composed: true,
                    }));
                } else {
                    window.open('/' + this.recordId,"_parent");
                }
            }) .catch(error => {
                
                console.log(error);
            });
            
    }
}