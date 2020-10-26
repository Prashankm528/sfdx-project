({
    doInit : function(component, event, helper) {
        helper.getRequestStatus(component, event);
    },
    
    handleSubmit : function(component, event, helper) {
        helper.createRecord(component, event);
    },
    
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})