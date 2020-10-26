({
    init : function(component, event) {
        var action = component.get("c.getStatus");
        
        action.setParams({
            "docRequestId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === 'SUCCESS'){
                component.set("v.status",response.getReturnValue());
                /*if(response.getReturnValue()=='DUP_Confirm_Details' || response.getReturnValue()=='DUP_Review_Upload'){
                    var cmpTarget = component.find('prev');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
        			$A.util.addClass(cmpTarget, 'slds-show');

                }
                else{
                    var cmpTarget = component.find('prev');
                    $A.util.removeClass(cmpTarget, 'slds-show');
        			$A.util.addClass(cmpTarget, 'slds-hide');

                }*/
                
            } else {
                //do something
            }
        });
        $A.enqueueAction(action);
    },
    
    showModal : function(component, event, isReverse) {
        var status = component.get("v.status");
        if(status==$A.get("$Label.c.DUP_Status_For_Popup") && !isReverse){
            var action = component.get("c.getSelectedocumentStore");
            action.setParams({
                "docRequestId": component.get("v.recordId")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();  
                var toShow = component.get("v.openPopup")                
                //var items = response.getReturnValue();
                if(component.isValid() && state == "SUCCESS"){
                    var returnedData = response.getReturnValue();
                    var displayData = null;
                    if(returnedData!=null && returnedData!=undefined)
                        displayData = (returnedData.toString()).split('--emailBody--');
                    if(displayData!=null && displayData[0].length>2 && displayData!=undefined){
                        if(toShow){
                            component.set("v.openPopup",false)
                        }
                        else{
                            component.set("v.openPopup",true)
                        }
                        var items = JSON.parse(displayData[0]);

                        if(displayData[1]!='null' && displayData[1]!=null && displayData[1]!=''){
                            component.set('v.emailBody', displayData[1]);
                        }
                        else{
                            component.set('v.emailBody', '<p>Please select a counterparty contact for each document to preview the email.</p>');
                        }
                        component.set('v.columns', [
                            {label: 'SELECTED', fieldName: 'DUP_Requested__c', type: 'boolean'},
                            {label: 'DOCUMENT NAME', fieldName: 'DUP_Document_Name__c', type: 'text'},
                            {label: 'CERTIFIED', fieldName: 'DUP_Certified_True_Copy__c', type: 'boolean'},
                            {label: 'COUNTERPARTY CONTACT', fieldName: 'url', type: 'url', typeAttributes: { label:{fieldName:"DUP_Counterparty_Contact_Name__c"},target: '_blank'}}
                        ]);
                        var dataRows=[];
                        for(var key in items){
                            var objInstance=new Object();
                            objInstance.DUP_Requested__c = items[key].DUP_Requested__c;
                            objInstance.DUP_Document_Name__c = items[key].DUP_Document_Name__c;
                            objInstance.DUP_Certified_True_Copy__c = items[key].DUP_Certified_True_Copy__c;
                            if(items[key].DUP_Counterparty_Contact_Name__r!=null && items[key].DUP_Counterparty_Contact_Name__r!=undefined){
                                objInstance.DUP_Counterparty_Contact_Name__c = items[key].DUP_Counterparty_Contact_Name__r.Name;
                                objInstance.url = "/lightning/r/"+items[key].DUP_Counterparty_Contact_Name__c+"/view";
                            }
                            else{
                                objInstance.DUP_Counterparty_Contact_Name__c = "";
                                objInstance.url = "";
                            }
                            
                            dataRows.push(objInstance);
                        }
                        
                        component.set("v.allSelectedDocs",dataRows);
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type":"info",
                            "title": "You encountered some errors when trying to save this record",
                            "message": "You must select and save at least one document"
                        });
                        toastEvent.fire();
                    }
                }
                
            });
            $A.enqueueAction(action);
        }
        else{
            this.updateStage(component,event, isReverse);
        }
    },
    
    updateStage : function(component, event, isReverseStage) {
        var action = component.get("c.updateDocReqStage");
        action.setParams({
            "docRequestId": component.get("v.recordId"),
            "currentStatus": component.get("v.status"),
            "isReverse": isReverseStage
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === 'SUCCESS'){
                var display =(JSON.stringify(response.getReturnValue())).split("--emailBody--");
                if(display!=null && display!='' && display!=undefined){
                    var temp =((display[0]).replace('"','')).replace('"','');
                    component.set("v.status",temp);
                    component.set("v.emailBody",display[1]);
                    this.showSuccessToast(component, event);
                    $A.get('e.force:refreshView').fire();
                }
                /*if(response.getReturnValue()=='DUP_Confirm_Details' || response.getReturnValue()=='DUP_Review_Upload'){
                    var cmpTarget = component.find('prev');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
        			$A.util.addClass(cmpTarget, 'slds-show');

                }
                else{
                    var cmpTarget = component.find('prev');
                    $A.util.removeClass(cmpTarget, 'slds-show');
        			$A.util.addClass(cmpTarget, 'slds-hide');

                }*/
                
            } else {
                var temp = JSON.stringify(response.getError()[0].message);
                var tempList = temp.split(',');
                this.showErrorToast(component, event, tempList[1].split(':')[0]);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    updateStageToPrevious : function(component, event) {
        var action = component.get("c.updateDocReqStageToPrev");
        
        action.setParams({
            "docRequestId": component.get("v.recordId"),
            "currentStatus": component.get("v.status")
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.status",response.getReturnValue());
                this.showSuccessToast(component, event);
                $A.get('e.force:refreshView').fire();
            } else {
                var temp = JSON.stringify(response.getError()[0].message);
                var tempList = temp.split(',');
                this.showErrorToast(component, event, tempList[1].split(':')[0]);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    showSuccessToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Status changed successfully."
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"error",
            "title": "You encountered some errors when trying to save this record",
            "message": message
        });
        toastEvent.fire();
    },
    
    cancelRequest : function(component, event) {
        var action = component.get("c.cancelRequest");
        
        action.setParams({
            "docRequestId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.status",'Cancelled');
                this.showSuccessToast(component, event);
                $A.get('e.force:refreshView').fire();
            } 
        });
        $A.enqueueAction(action);
    }
    
})