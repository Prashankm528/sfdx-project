import { LightningElement,track,api } from 'lwc';

export default class GcmChild extends LightningElement {
    
    @track _substatus;
    @track pendingApproval;
    @track approved;

    @api
    get substatus() {
        return (this._substatus);
    }      
    set substatus(value) {
        if(this._substatus != value){
            this.setAttribute('substatus', value);
            this._substatus = value;
            if(this._substatus === 'Pending - Int Approval'){            
                this.pendingApproval = true;
                this.approved = false;
            }
            if(this._substatus === 'Approved'){            
                this.approved = true;
                this.pendingApproval = false;
            }
        }                 
    }
}