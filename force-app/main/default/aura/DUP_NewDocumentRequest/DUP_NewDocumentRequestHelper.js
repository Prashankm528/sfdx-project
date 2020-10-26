({
    loadData : function(component, event, helper) {
        var action = component.get("c.loadSelectsValues");

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var wrapper = response.getReturnValue();
                component.set("v.lovList" , wrapper.listOfValuesList);
                component.set("v.docTemplateList" , wrapper.docTemplateList);
            } else {
                console.log("Problem getting wrapper data, response state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    createNewDocStore : function(component, event, helper) {
        component.set("v.showSpinner" , true);
        component.set("v.newDocStore.DUP_Document_Request__c", component.get("v.recordId"));
        component.set("v.newDocStore.DUP_Document_Status__c", "Created");
        component.set("v.newDocStore.DUP_Requested__c", false);
        component.set("v.newDocStore.Id", null);
        var action = component.get("c.createDocStore");
        action.setParams({
            "docStore": component.get("v.newDocStore")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.docStoreId", response.getReturnValue());
            } else {
                console.log("Problem create new document store, response state: " + state);
            }
            component.set("v.showSpinner" , false);
            helper.createFileUploadComponent(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    updateDocStore : function(component, event, helper) {
        component.set("v.showSpinner" , true);
        component.set("v.newDocStore.Id", component.get("v.docStoreId"));
        if((component.get("v.contentDocument")).length>0){
            component.set("v.newDocStore.DUP_ManualUpload__c", true);
        }
        var action = component.get("c.createDocStore");
        action.setParams({
            "docStore": component.get("v.newDocStore")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var event = component.getEvent("newDocumentEvent");
                var docStore = component.get("v.newDocStore");
                var contentDoc = component.get("v.contentDocument");
                docStore.Id = response.getReturnValue();
                if(docStore.DUP_Document_Template__c!=null && docStore.DUP_Document_Template__c!=''){
                    docStore.DUP_Document_Template__r = new Object();
                    docStore.DUP_Document_Template__r.Id = docStore.DUP_Document_Template__c;
                    docStore.DUP_Document_Template__r.Name = component.get("v.selectedTemplate");
                }
                event.setParam("isNewDocument", true);
                event.setParam("contentDocument", contentDoc);
                event.setParam("newDocStore", docStore);
                event.fire();

                component.set("v.modalNewDocStore" , false);
                component.set("v.openModal", false);
            } else {
                console.log("Problem create new document store, response state: " + state);
            }
            component.set("v.showSpinner" , false);
            
        });
        $A.enqueueAction(action);
    },
    deleteDocStore : function(component, event, helper) {
        component.set("v.showSpinner" , true);
        component.set("v.newDocStore.Id", component.get("v.docStoreId"));
        var action = component.get("c.deleteDocStore");
        action.setParams({
            "docStore": component.get("v.newDocStore")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {                
                component.set("v.modalNewDocStore" , false);
                component.set("v.openModal", false);
            } else {
                console.log("Problem deleting new document store, response state: " + state);
            }
            component.set("v.showSpinner" , false);
            
        });
        $A.enqueueAction(action);
        var event = component.getEvent("newDocumentEvent");
                //var docStore = component.get("v.newDocStore");
                //docStore.Id = response.getReturnValue();
                event.setParam("isNewDocument", false);
                event.setParam("newDocStore", null);
                event.fire();
    },
    updateStatusAndGetFileList : function(cmp, evt, hlp) {  
        var action = cmp.get("c.UpdateStatusAndReturnFiles");
        action.setParams({
            "docStoreId": cmp.get("v.docStoreId")
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == null) return;
                cmp.set("v.contentDocument", result);
                if(result.length >= 1){
                    cmp.set("v.countDocStoreUploaded", cmp.get("v.countDocStoreUploaded") + 1);
                }                
                cmp.set("v.counterFiles", result.length); 
                if(result.length >= 1){
                    cmp.set("v.newDocStore.DUP_Document_Template__c", null);
                }
				
            } else {
                console.log('Problem updating document status, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    shareWithCounterParty : function(cmp, evt, hlp) { 
        var uploadedFiles = evt.getParam("files");        
        var action = cmp.get("c.shareFileWithCounterParty");
        var size = $A.get("$Label.c.DUP_File_Size");
        action.setParams({
            "docStoreId": cmp.get("v.docStoreId"),
            "files": JSON.stringify(uploadedFiles)            
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state == "SUCCESS") {
                 if(response.getReturnValue()!=='OK'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The file you are trying to upload is too large. Files must be under "+size+" MB in size.",
                        "type" : "error"
                    });
                    toastEvent.fire();
                 }else{
                     this.updateStatusAndGetFileList(cmp, evt, hlp);
                 }
            } else {
                console.log('Problem sharing document, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    loadTemplateValues : function(component, event, helper) {
        var selectedTemplateId = component.get("v.newDocStore.DUP_List_Of_Value__c");
        var templateList = component.get("v.lovList");

        component.set("v.newDocStore.DUP_Document_Name__c", null);
        component.set("v.newDocStore.DUP_Description__c", null);
        component.set("v.newDocStore.DUP_Document_Template__c", null);

        if(selectedTemplateId != null && templateList != null){
            for(var i = 0; i < templateList.length; i++){
                if(templateList[i].Id == selectedTemplateId){
                    component.set("v.newDocStore.DUP_Document_Name__c", templateList[i].DUP_Type__c);
                    component.set("v.newDocStore.DUP_Description__c", templateList[i].DUP_Description__c);
                    if(component.get("v.counterFiles") >= 1){
                        component.set("v.newDocStore.DUP_Document_Template__c", null);
                    }else{
                        component.set("v.newDocStore.DUP_Document_Template__c", templateList[i].DUP_Document_Template__c);
                        component.set("v.selectedTemplate", templateList[i].DUP_Type__c);
                    }
                    if(component.get("v.newDocStore.DUP_Document_Template__c") == null){
                        component.find("fileUploadButton").set("v.disabled",false);
                    }else{
                        component.find("fileUploadButton").set("v.disabled",true);
                    }
                    break;
                }
            }
        }
    },
    createFileUploadComponent : function(component, event, helper){
        var vId = component.get("v.docStoreId");
        var size = $A.get("$Label.c.DUP_File_Size");
        $A.createComponent(
            "lightning:fileUpload",
            {
                "aura:id": "fileUploadButton",
                "name":"fileUploader",
                "label":"There is a "+size+"  MB size limit per file.",
                "multiple":"true",
                "recordId":vId,
                "onuploadfinished":component.getReference("c.showUploadedDocument")
            },
            function(newFileUpload, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newFileUpload);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
    
    handleValidation : function(component, event, helper) {
        var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            this.updateDocStore(component, event, helper);
        } 
    }
})