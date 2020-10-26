({
    recordUpdated : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
        	if(component.get("v.simpleRecord.ContactId") == null){
            	component.set("v.noContact", true);
        	}
            else{
                component.set("v.noContact", false);
            }
    	}
	},
    reloadComponent : function(component, event, helper) {
    
        component.find('recordLoader').reloadRecord(true);
    }

 })