({
	doInit : function(component, event, helper) {
        helper.init(component);
    },
    
    save : function(component, event, helper) {
        helper.save(component);
    },
    
    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    onStatusPicklist : function(component, event, helper) {
        helper.onStatusPicklist(component);
    },
   
    radioNPS: function(component, event, helper) {
        helper.radioNPS(component, event);
    },
    
    radioCES: function(component, event, helper) {
        helper.radioCES(component, event);
    },
    
    reason: function(component, event, helper) {
        helper.reason(component);
    }
})