({
    doInit : function(component, event, helper) {
        component.set("v.spinner",true);
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        component.set("v.parentId", addressableContext.attributes.recordId);
        var currRecId = component.get("v.recordId");
        if (currRecId == null) {
            component.set("v.lgtMode", "New");
            component.set("v.isNew", true);
        } else {
            component.set("v.lgtMode", "Edit");
            component.set("v.isNew", false);
            var action = component.get("c.fetchCommercialOpportunityRecord");
            action.setParams({
                recordId : currRecId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    component.set("v.selectedProductRecord", storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
        component.set("v.spinner",false);
               
    },
    
    handleOnLoad : function(component, event, helper) {
        var currRecId = component.get("v.recordId");
        if (currRecId == null) {
            component.set("v.lgtMode", "New");
            component.set("v.isNew", true);
        } else {
            component.set("v.lgtMode", "Edit");
            component.set("v.isNew", false);
        }
        component.set("v.terminalId", component.find('terminalLookupId').get('v.value'));
        if (!component.get("v.isNew")) {
            var childComponent = component.find("prodLookUpId");
            var message = childComponent.loadTerminalMethod(component.get("v.isNew"));
            console.log(message);
            helper.terminalChangeHelper(component,event);
        }
        var recUi = event.getParam("recordUi");
        if(recUi.record.fields["GEFUE_Product__c"].value == null){
            var childCmp = component.find('prodLookUpId');
            childCmp.clearProduct();
        }
    },
    
    handleSubmitClick: function(component, event, helper){
        helper.showSpinner(component);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");
       // var currRecID = component.get("v.recordId");
        if(component.get("v.selectedProductRecord") != undefined){
            fields["GEFUE_Product__c"] = component.get("v.selectedProductRecord").GEFUE_Product__c;
        }else{
            fields["GEFUE_Product__c"] = null;
        }
        component.find('recordViewForm').submit(fields); // Submit form
        //console.log("ON Submit > "+fields["GEFUE_Product__c"]);
        let button = component.find('save');
    button.set('v.disabled',true);
        helper.hideSpinner(component);
    },
    
    handleSuccess: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.parentId"),
            "slideDevName": "related"
        });
        navEvt.fire(); 
        var successStr = 'Record has been ';
        if (component.get("v.isNew")) {
            successStr += 'created';
        } else {
            successStr += 'edited';
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "mode": 'dismissible',
            "duration":' 4000',
            "type": 'success',
            "message": successStr
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
        
    },
    onCancel : function(component,event,helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.parentId"),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    terminalChange : function(component,event,helper) {
        component.set("v.terminalId", component.find('terminalLookupId').get('v.value'));
        helper.terminalChangeHelper(component,event);
        var childCmp = component.find('prodLookUpId');
        childCmp.clearProduct();
        component.set("v.selectedProductRecord",undefined);
      
    },
    
    handleProductClose : function(component,event,helper) {
        component.set("v.selectedProductRecord",undefined);
    },
    
    setErrorMessage : function(component, event, helper) {
        var termAddBoolean = event.getParam("terminalError");
        component.set("v.showTerminalError" , termAddBoolean);
    }
})