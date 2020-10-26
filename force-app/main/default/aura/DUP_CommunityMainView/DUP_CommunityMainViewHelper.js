/*****************************************************************************************
*       Date:        19Set2019
*       Author:      Alessandro Miele - IBM
*       Description: JS Helper for DUP_CommunityMainView 
*****************************************************************************************/
({
    searchDocuments: function (cmp, evt, hlp, docReqName) {
        var action = cmp.get("c.getDocumentStore");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        cmp.set("v.isCertifiedPresent", false);
        //var docReqName = cmp.find("docReqName").get("v.value");
        cmp.set("v.documentRequestName", docReqName);
        action.setParams({
            "docReqName": docReqName,
            "userId": userId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var docStoreList = response.getReturnValue();
                if (docStoreList.length == 0) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "No document request found. Please verify your ID.",
                        "type": "error"
                    });
                    toastEvent.fire();
                } else {
                    $A.util.removeClass(cmp.find("submitDocs"), 'slds-hide');
                    $A.util.removeClass(cmp.find("docList"), 'slds-hide');
                    //added by ajay
                    $A.util.removeClass(cmp.find("expandDocs"), 'slds-hide');

                    var temp = [];
                    var flag = false;
                    for (var i = 0; i < docStoreList.length; i++) {
                        var tempObj = new Object();
                        tempObj.storeId = docStoreList[i].Id;
                        tempObj.uploaded = 0;
                        temp.push(tempObj);
                        if (!flag && docStoreList[i].DUP_Certified_True_Copy__c) {
                            cmp.set("v.isCertifiedPresent", true);
                            flag = true;
                        }
                    }
                    cmp.set("v.uploadedPerFile", temp)
                }
                cmp.set("v.docStoreList", docStoreList);

            } else {
                console.log('Problem getting document Store, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    submitDocuments: function(cmp, evt, hlp) {
        
        var uploadedPerFile = cmp.get("v.uploadedPerFile");
        
        for(var key in uploadedPerFile){
            if(uploadedPerFile[key].uploaded == 0){
                var toastEvent = $A.get("e.force:showToast");
            	toastEvent.setParams({
                "title": "Error!",
                "message": "Please upload a document for each request.",
                "type" : "error"
            });
            toastEvent.fire(); 
            return;
            }
        }
        /*if(!(cmp.get("v.countDocStoreUploaded") >= cmp.get("v.docStoreList").length)) {

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please upload a document for each request.",
                "type" : "error"
            });
            toastEvent.fire(); 
            return;
        }*/

        var action = cmp.get("c.uploadDocStoreStatus");
        action.setParams({
            "docStoreList" : cmp.get("v.docStoreList")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "All documents have been submitted.",
                    "type" : "success"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('response state: ' + state);
            }
        });
        $A.enqueueAction(action);        

    }  
})