({
    doInit : function(component, event, helper) {
        
        // Get type of the object to which task belongs to and all parent specific information.
        helper.getParentSpecificDetails(component, event, helper);
        helper.getTaskType(component, event, helper);
        
              
    	// Get the pickliust values for Task.Priority field 
   		// This is a workaround for lightning bug rendering force:inputField picklists as disabled 
    	helper.getTaskPriorityValues(component, event, helper);

        // Retrieve details of the task and related Account info
        helper.getTaskDetails(component, event, helper);
    },
    handleCancel : function(component, event, helper) {
      	// Close the quick action 
      	$A.get("e.force:closeQuickAction").fire();
   	},
    handleSave : function(component, event, helper) {
    	//Save the Task
    	helper.saveTask(component, event, helper);
   }

})