({
    displayLogic : function(component, event, helper) {
        if(component.get("v.fileId") != null && component.get("v.context") == "ErrorFile"){            
            $A.util.removeClass(component.find("operationButton"), "slds-hide");  
            $A.util.removeClass(component.find("previewElement"), "slds-hide");                       
        }
        if(component.get("v.context") == "fileInSharepoint"){   
            $A.util.removeClass(component.find("sharepointLink"), "slds-hide"); 
            component.set("v.sentToSP",true);
        } 
        this.checkPermission(component, event);
    },

    sendToSharepoint : function(cmp, evt, hlp) {
        cmp.set("v.isSpinner", true);
        var action = cmp.get("c.sendFileToSharepoint");
        action.setParams({
            "docStore": cmp.get("v.documentStore"),
            "contentVersionId": cmp.get("v.contentVersionId")
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {                
                var result = response.getReturnValue();
                if(result == null){
                    return;
                }                
                cmp.set("v.contentDocument" , result.contentDocumentLinkList);
                cmp.set("v.fileInfoList" , result.fileInfoList);
                cmp.set("v.isSpinner", false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Call to sharepoint performed",
                    "message": "Please check individual file for status.",
                    "type" : "info"
                });
                toastEvent.fire();       
            } else {
                cmp.set("v.isSpinner", false);
                console.log('Problem updating document status, response state: ' + state);
            }
        });
        $A.enqueueAction(action);        
    },
    saveFileName : function(component, event) {
        var fileName = component.find('fileName').get("v.value");
        var action = component.get("c.updateFileName"); 
        action.setParams({
            "contentVersionId": component.get("v.contentVersionId"),
            "fileName": fileName 
        });  
        $A.enqueueAction(action);    
    },
    downloadDocument: function(component, event){
        var downloadUrl= $A.get("e.force:navigateToURL");
        var fileId = component.get("v.fileId");
        var baseUrl = $A.get("$Label.c.BPISTDUPLightningBaseUrl");
        
        downloadUrl.setParams({
            "url": baseUrl + '/sfc/servlet.shepherd/document/download/' + fileId
        });
        downloadUrl.fire();
    },
    checkPermission : function(component, event) {
        var action = component.get("c.checkPermission");
        
        action.setParams({
            "permissionName": 'DUP_SuperUser'
        }); 
        action.setCallback(this, function(response) {   
                var state = response.getState();
                if(state === "SUCCESS") {                
                    var result = response.getReturnValue();
                    component.set("v.isSuperUser" , result);
                    
                }
            });
        $A.enqueueAction(action);
    }
})