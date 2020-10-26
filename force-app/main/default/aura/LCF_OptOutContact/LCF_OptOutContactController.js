({
    doInit : function(component, event, helper) {
    
    	// Get data
    	helper.getEmail(component, event, helper);
    	helper.getPermission(component, event, helper);
    	helper.isOptedOut(component, event, helper);
    	helper.hasAnEmail(component, event, helper);	
    	        
    },
    handleCancel : function(component, event, helper) {
      	// Close the quick action 
      	$A.get("e.force:closeQuickAction").fire();
   	},
    handleSave : function(component, event, helper) {
    	//Opt out contact
    	helper.optOut(component, event, helper);
   }

})