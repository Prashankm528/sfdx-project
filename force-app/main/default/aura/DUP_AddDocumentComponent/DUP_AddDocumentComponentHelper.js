({
    getAllDocumentStore: function(cmp, evt, hlp) {    
        var action = cmp.get("c.getDocumentStore");
        action.setParams({"docRequestId": cmp.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                cmp.set("v.projectDocument", response.getReturnValue());                
                cmp.set("v.documents",response.getReturnValue()); 
            } else {
                console.log('Problem getting document Store, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    sendCommunicationHelper: function(cmp, evt, hlp) {    
        var action = cmp.get("c.sendReminder");
        action.setParams({"docRequestId": cmp.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
              var emailinovc = response.getReturnValue();
                console.log('emailinovc',emailinovc);
                if(emailinovc > 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The notifications have been sent.",
                    "type" : "success"
                });
                    toastEvent.fire();    
                }
                else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Problem Sending Email, Please Check Document status if already submitted/approved.",
                    "type" : "Error"
                });  
                    toastEvent.fire();    
                }
                                         
            } else {
                console.log('Problem sending email, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },  

    sendRejectionCommunicationHelper: function(cmp, evt, hlp) {    
        var action = cmp.get("c.sendRejection");
        action.setParams({"docRequestId": cmp.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The notifications have been sent.",
                    "type" : "success"
                });
                toastEvent.fire();               
            } else if(state === "ERROR") {                
                 var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    "title": "Sorry!",
                    "message": "Please Check the following to send rejection email : 1. All files are uploaded 2. All uploaded files are reviewed 3. Rejection comments are added as required",
		    "type" : "error"
                });
                toastEvent.fire(); 
                console.log('Problem sending email, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },    
    changeCPContact: function(cmp, evt) {    
        var action = cmp.get("c.changeCounterPartyContact");  
        var selected = cmp.get("v.selectedCPId");
	var sMsg = 'The contact cannot be changed';
        sMsg += ' as the previously selected contact has already started the file upload process';
        sMsg += ' or multiple counterparties are selected for this request.';
        sMsg += ' Kindly communicate the same to the concerned counterparty.';

        if(selected!=null && selected!='' && selected!=undefined){
        action.setParams(
            {
                "docRequestId": cmp.get("v.recordId"),
                "counterParty": selected,
                "newEmail" : cmp.get("v.selectedCPEmail")
            }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.modalCPChange",false);
                if(result=='Updated'){
                    var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    "title": "Success!",
                    "message": "The notification has been sent to the selected Counterparty Contact.",
                    "type" : "success"
                });
                toastEvent.fire(); 
                }
                else if(result=='NoUpdate'){
                    var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    "title": "Warning!",
                    "message": sMsg,
                    "type" : "warning"
                });
                toastEvent.fire(); 
                }
            } else {
                console.log('Problem getting document Store, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    "title": "Warning!",
                    "message": "No counterparty contact has been selected!",
                    "type" : "warning"
                });
                toastEvent.fire(); 
        }
    },
    handleEvent : function(component, event) {
        var lookupEventToParent = event.getParam("selectedItem");
        component.set("v.selectedCPId", lookupEventToParent.Id);
        component.set("v.selectedCP", lookupEventToParent.Name);
        component.set("v.selectedCPEmail", lookupEventToParent.DUP_Email__c);
        component.set("v.searchText", null);
                   
    },
    
    handleRemoveOnly : function(component, event) {
        component.set("v.selectedCPId", null);
        component.set("v.selectedCP", null);
        component.set("v.selectedCPEmail", null);
        component.set("v.searchText", null);
    },
    onchange : function(component, event) {
        var action = component.get("c.getLookupList");
        var term = event.getSource().get( "v.value" );

        action.setParams({
            "searchTerm" :  term,
            "objName" : "DUP_Counterparty_Contact__c"
        });
        
        if(term.length > 0){
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS")  {
                    var result = response.getReturnValue();
                    component.set("v.conList", result);
                    if(term != "" && result.length > 0){
                        var ToOpen = component.find("toOpen");
                        $A.util.addClass(ToOpen, "slds-is-open");
                    }else{
                        var ToOpen = component.find("toOpen");
                        $A.util.removeClass(ToOpen, "slds-is-open");
                    }
                }
                
            });
            
            $A.enqueueAction(action);
        }
    },
})