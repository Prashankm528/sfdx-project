/*****************************************************************************************
*       Date:        20Set2019
*       Author:      Alessandro Miele - IBM
*       Description: Js Helper for DUP_CommunitySingleDocumentView
*       Updated by:  Arron Kukadia - IBM (shareFileWithAgent to handle multiple files uploaded)
*****************************************************************************************/
({
    loadFile : function(cmp, evt, hlp) {     
        cmp.set("v.cp_Comments",cmp.get("v.document").DUP_CPcomments__c);
        var action = cmp.get("c.getUploadedFile");
        var docstoreId = cmp.get("v.documentId");
        action.setParams({
            "docStoreId": docstoreId
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == null) return;
                //added by Sunaiyana for doc upload mismatch bug
                //var uploadedDocsCount = [];
                var uploadedPerFile = cmp.get("v.uploadedPerFile");
                
                for(var key in uploadedPerFile){
                    if(uploadedPerFile[key].storeId == docstoreId){
                        for(var i=0;i<result.length;i++){
                            if(result[i].ContentDocument.LatestPublishedVersion.DUP_Status__c=='Uploaded'){
                                //uploadedDocsCount.push(result[i].LinkedEntityId);
                                uploadedPerFile[key].uploaded = uploadedPerFile[key].uploaded + 1;
                            }
                        }
                        break;
                    }
                }
                cmp.set("v.uploadedPerFile",uploadedPerFile);
                
                /*if(uploadedDocsCount!=null && uploadedDocsCount.length>0){
                    var temp = uploadedDocsCount.filter(function(item, pos){
                        return uploadedDocsCount.indexOf(item)== pos; 
                    });
                    //if(temp!=null && temp.length>0)
                        //cmp.set("v.countDocStoreUploaded", temp.length);
                }*/
                //
                cmp.set("v.contentDocument", result);
                cmp.set("v.counterFiles", result.length);                 
            } else {
                console.log('Problem updating document status, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    /*cleanOldFilesHelper : function(cmp, evt, hlp) {                
        var fileName = evt.getParam("files")[0].name;
        var fileId = evt.getParam("files")[0].documentId;
        cmp.set("v.fileName", fileName);
        cmp.set("v.fileId", fileId); 
        $A.util.removeClass(cmp.find("deleteButton"), 'slds-hide');
        $A.util.removeClass(cmp.find("previewElement"), 'slds-hide');  
        var action = cmp.get("c.deleteFiles");
        action.setParams({
            "docStoreId": cmp.get("v.documentId"),
            "fileId": fileId
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                if(!response.getReturnValue()){
                    cmp.set("v.countDocStoreUploaded", cmp.get("v.countDocStoreUploaded") + 1);
                }
            } else {
                console.log('Problem updating document status, response state: ' + state);
            }
        });
        $A.enqueueAction(action);         
        
    },*/
    
    shareFileWithAgent: function (cmp, evt, hlp) {
        var action;
        var fileIds = [];
        var uploadedFiles = evt.getParam("files");
        var fileIdsToDelete = [];
        var fileIdsToKeep = [];
        var temp = uploadedFiles;
        var deleteFile = false;
        var specialChars = $A.get("$Label.c.DUP_CharactersNotAllowed");
        
        for (var i = 0; i < temp.length; i++) {
            var file = temp[i];
            var name = file.name;
            var tempObj = new Object();
            tempObj.Id = file.documentId;
            tempObj.file = file;
            tempObj.toDelete = false;
            var chars = specialChars.split("");

            for (var j=0;j<chars.length;j++){
                if (name.indexOf(chars[j]) > -1) {
                    tempObj.toDelete = true;
                    break;
                }
            }
            
            fileIds.push(tempObj);
        }

        for (var key in fileIds) {
            if (fileIds[key].toDelete) {
                fileIdsToDelete.push(fileIds[key].Id);
            }
            else {
                fileIdsToKeep.push(fileIds[key].file);
            }
        }
        uploadedFiles = fileIdsToKeep;
        if (uploadedFiles.length > 0) {
            action = cmp.get("c.shareFileWithAgent");
            var size = $A.get("$Label.c.DUP_File_Size");
            action.setParams({
                "docStoreId": cmp.get("v.documentId"),
                "files": JSON.stringify(uploadedFiles)
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    if (response.getReturnValue() !== 'OK') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "The file you are trying to upload is too large. Files must be under " + size + " MB in size.",
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log('Problem sharing document, response state: ' + state);
                }
            });
            $A.enqueueAction(action);
        }
        if (fileIdsToDelete.length > 0) {
            action = cmp.get("c.deleteInvalidDocument");
            action.setParams({
                "fileIds": JSON.stringify(fileIdsToDelete)
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    if (response.getReturnValue() !== 'OK') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please ensure that file name does not contain any special characters or symbols, and try to upload the file again.",
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log('Problem deleting document, response state: ' + state);
                }
            });
            $A.enqueueAction(action);
        }

    },    
    refreshListFile : function(cmp, evt, hlp) {  
        var action = cmp.get("c.getUploadedFile");
        var docId = cmp.get("v.documentId")
        action.setParams({
            "docStoreId": docId
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                
                if(result == null) return;
                cmp.set("v.contentDocument", result);
                if(result.length >= 1){
                    var uploadedPerFile = cmp.get("v.uploadedPerFile");
                    
                    for(var key in uploadedPerFile){
                        if(uploadedPerFile[key].storeId == docId){
                            for(var i in result){
                                if(result[i].ContentDocument.LatestPublishedVersion.DUP_Status__c == 'Uploaded'){
                                	uploadedPerFile[key].uploaded = uploadedPerFile[key].uploaded + 1;
                                }
                            }
                            break;
                        }
                    }
                    cmp.set("v.uploadedPerFile",uploadedPerFile);
                    
                }                
                cmp.set("v.counterFiles", result.length);                 
            } else {
                console.log('Problem updating document status, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    addComments : function(component, event) { 
        var comment = component.get("v.document.DUP_CPcomments__c");
        component.set("v.cp_Comments",comment);
    	var action = component.get("c.saveComments");
        var docId = component.get("v.documentId");

        action.setParams({
            "docStoreId": docId,
            "cpcomments": comment
        }); 

        action.setCallback(this, function(response) { 
            var state = response.getState();
            if(state == "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Comments Saved",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set('v.openModal2', false); 
            } else {
                console.log('Problem saving comments, response state: ' + state);
            }
        });        
        $A.enqueueAction(action);
    },
	
	toggleHelper : function(cmp){
        var sectionDiv = cmp.find('sectionDiv');
        $A.util.toggleClass(sectionDiv, 'slds-is-open');
        var toggleText = cmp.find('linksSection');
        $A.util.toggleClass(toggleText, 'toggle');
    }
})