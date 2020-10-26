({    
    GenerateDocument: function(component, event, helper) {
        var approver = component.get("v.caseRecord.GCP_TFD_Approver_Last_Name__c");
        var autoApproved = component.get("v.caseRecord.GCP_TFD_Approver_Cherck__c");
        var recordTypeName = component.get("v.caseRecord.RecordType.DeveloperName");
        if(recordTypeName != 'GCP_TFD_Discounting')
        {
            component.set("v.isOpen", true);
        }
        else
        {
        	if(recordTypeName === 'GCP_TFD_Discounting' && approver === 'Not Exists' && autoApproved != 'Auto Approved')
        	{
            	alert($A.get("$Label.c.GCP_TFD_APPROVER_REQUIRED"));
        	}
        	else
        	{
        		helper.displayMessage(component,event);    
        	}    
        }        
    },
    doInit : function(component,event,helper){
    	helper.onLoad(component,event); 
    },
    closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
    },
    generateDoc: function(component, event, helper) {
        helper.updateCase(component,event);
        helper.displayMessage(component,event); 
    },
    onGroup: function(cmp, evt) {
		 var selected = evt.getSource().get("v.label");
		 cmp.set("v.genericTemplate", selected);
	 }
    
})