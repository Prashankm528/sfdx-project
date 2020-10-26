import { LightningElement, api, wire, track} from 'lwc';
import getData from '@salesforce/apex/DUP_CommunityMainViewCtrlLWC.getRelatedRequests';
import { refreshApex } from '@salesforce/apex';

export default class DUP_CommunityMainViewControllerLWC extends LightningElement {
@api docReqList;
@api available;
@api wiredResults
@track selectedId

@api
handleRefresh()
{
    return refreshApex(this.wiredResults);
}

clickHandler(event) {
    // Get the labels of selected checkboxes
    var selectedId = ((event.target.id).split('-'))[0];
    
    const showDocsToUpload = new CustomEvent('showDocUploader', {
        detail: { selectedId },
    });
    // Fire the custom event
    this.dispatchEvent(showDocsToUpload);
    var data = this.docReqList;
    for(var key in data){
        if(data[key].reqName==selectedId){
            data[key].styleClass = 'highlight';
        }
        else{
            data[key].styleClass = '';
        }
    }
    this.docReqList = data;
}

@wire(getData)
imperativeWiring(result) {
    this.wiredResults = result;
    if (result.data) {
        var data = result.data;
        var temp = [];
        for(var key in data){
            var tempObj = new Object();
            tempObj.reqId = data[key].Id;
            tempObj.reqName = data[key].DUP_CounterParty_Name__c;
            tempObj.styleClass = '';
            tempObj.pendingDocs = data[key].DUP_Items_Received__c;
            temp.push(tempObj);
        }
        if(temp.length>0){
            this.available = true;
        }
        else{
            this.available = false;
        }
        this.docReqList = temp;
        
    } else if (result.error) {
        console.log("error:-  "+result.error);
    }
}

}