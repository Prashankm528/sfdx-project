({
	doInit: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var objectName = component.get("v.sobjecttype");
        if(objectName === 'GCP_TFD_OpenCredit__c'){
        	helper.callApexMethodOc(component,event,helper);          
        }
        if(objectName === 'GCP_TFD_Letter_of_Credit__c'){
        	helper.callApexMethodLc(component,event,helper);          
        }
    }
})