({
    displayLogic : function(component, event, helper) {
        if(component.get("v.fileId") != null && component.get("v.context") == "External"){            
            $A.util.removeClass(component.find("deleteButton"), "slds-hide");  
            $A.util.removeClass(component.find("previewElement"), "slds-hide");                       
        }
        if(component.get("v.fileId") != null && component.get("v.context") == "Internal"){
            if(component.get("v.document.DUP_Document_Status__c") != 'Requested'){
                if(component.get("v.fileStatus") == "Uploaded"){
                    $A.util.removeClass(component.find("operationButton"), "slds-hide");
                }  
                $A.util.removeClass(component.find("previewElement"), "slds-hide"); 
            } 
            else if(component.get("v.document.DUP_Document_Status__c") == 'Requested' && component.get("v.fileStatus") == "Approved"){
            	$A.util.removeClass(component.find("previewElement"), "slds-hide");  
            } 
            else {
                if(component.get("v.fileStatus") == "Template"){
                    $A.util.removeClass(component.find("previewElement"), "slds-hide");
                }
            }
            
        } 
        
    },
    
    deleteDocumentAndRefresh: function(cmp, evt, hlp) {
        var action = cmp.get("c.deleteSingleDocumentAndRefreshList");
        var docstoreId = cmp.get("v.documentId");

        action.setParams({
            "fileId": cmp.get("v.fileId"),
            "docStoreId": docstoreId
        }); 
        
        var tempStatus = cmp.get("v.fileStatus");
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "File removed",
                    "message": "If needed, please load a new document.",
                    "type" : "info"
                });
                toastEvent.fire();
                var deleteEvent = cmp.getEvent("removeDeletedFiles");
                var result = response.getReturnValue();
                deleteEvent.setParams({
                    "contentDocument" : result
                });
                deleteEvent.fire();
                cmp.set("v.counterFiles", cmp.get("v.counterFiles") - 1);
                var uploadedPerFile = cmp.get("v.uploadedPerFile");

                if(uploadedPerFile.length > 0){
                    for(var key in uploadedPerFile){
                        if(uploadedPerFile[key].storeId == docstoreId){
                            if(tempStatus!="Template"){
                                uploadedPerFile[key].uploaded = uploadedPerFile[key].uploaded - 1;
                            }
                            break;
                        }
                    }
                    cmp.set("v.uploadedPerFile",uploadedPerFile);
                }
                cmp.set("v.contentDocument", result);
            } else {
                console.log("Response state: " + state);
            }
        });
        $A.enqueueAction(action);        
    },

    rejectDocumentNoReq: function(cmp, evt, hlp) {
        var newCounterFiles = cmp.get("v.counterFiles") - 1;

        cmp.set("v.document.DUP_Reject_Comments__c", cmp.find("rejectComment").get("v.value"));
        var action = cmp.get("c.rejectSingleDocument");
        action.setParams({
            "fileId": cmp.get("v.fileId"),
            "docStore": cmp.get("v.document"),
            "statusUpdate": "Reviewed"
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.counterFiles", newCounterFiles);
                for(var key in result){
                    var temp = key.split(':');
                    cmp.set("v.document.DUP_RejectComments_Available__c",temp[1]);
                    cmp.set("v.document.DUP_Document_Status__c",temp[0] );
					cmp.set("v.contentDocument", result[key]);
                }
                    cmp.set("v.document", cmp.get("v.document"));
                    $A.get('e.force:refreshView').fire();

            } else {
                console.log("Response state: " + state);
            }
        });
        $A.enqueueAction(action);        
    },
    
    rejectDocumentWithReq: function(cmp, evt, hlp) {
        var comment = cmp.find("rejectComment").get("v.value");
        if(comment!='' && comment!=null){
        cmp.set("v.document.DUP_Reject_Comments__c",comment );
        var action = cmp.get("c.rejectSingleDocument");
        action.setParams({
            "fileId": cmp.get("v.fileId"),
            "docStore": cmp.get("v.document"),
            "statusUpdate": 'Requested'
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                for(var key in result){
                    var temp = key.split(':');
                    cmp.set("v.document.DUP_RejectComments_Available__c",temp[1]);
                    cmp.set("v.document.DUP_Document_Status__c",temp[0] );
					cmp.set("v.contentDocument", result[key]);
                }
                cmp.set("v.document", cmp.get("v.document"));  
                $A.get('e.force:refreshView').fire();          
            } else {
                console.log("Response state: " + state);
            }
        });
        $A.enqueueAction(action); 
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Comments Required",
                    "message": "Rejection comments are required!",
                    "type" : "warning"
                });
            toastEvent.fire();
        }
    },
    
    approveDocument: function(cmp, evt, hlp) {
        var updateStatus = false;
        var newCounterFiles = cmp.get("v.counterFiles") - 1;
        
        var action = cmp.get("c.approveSingleDocument");
        action.setParams({
            "fileId": cmp.get("v.fileId"),
            "docStore": cmp.get("v.document"),
            "updateStatus" : updateStatus
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
		cmp.set("v.document", result.ds);
                cmp.set("v.contentDocument", result.contentDocumentList); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Document Approved",
                    "message": "The file is ready to be submitted to the repository.",
                    "type" : "success"
                });
                toastEvent.fire();
                cmp.set("v.counterFiles", newCounterFiles); 
                $A.util.addClass(cmp.find("operationButton"), "slds-hide");
                $A.get('e.force:refreshView').fire();
            } else {
                console.log("Response state: " + state);
            }
        });
        $A.enqueueAction(action);          
    }
})