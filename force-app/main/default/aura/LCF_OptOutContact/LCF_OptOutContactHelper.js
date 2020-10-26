({
	optOut : function(component, event, helper) {
	
		var errorMessages = [];
		var taskHasErrors = false
        
        if(component.get("v.hasPermission") == false){
            errorMessages.push({value:" You do not have the permission to opt out this Contact. Please contact your CX Operations Manager."});
            taskHasErrors = true;
        } 

		if(errorMessages == false){	
	
        	var action = component.get("c.optOut");		
        	action.setParams({"recordId": component.get("v.recordId")});
        
        	action.setCallback(this, function(response) {   
        	var state = response.getState();
            if(component.isValid() && state == "SUCCESS" && response.getReturnValue()){
                
            			$A.get('e.force:refreshView').fire();
                    	$A.get("e.force:closeQuickAction").fire();
                    	var toastEvent = $A.get("e.force:showToast");
                    	
                    	if(component.get("v.isOptedOut") == true){
                    	    toastEvent.setParams({
                        	"message": "Contact is already Opted Out",
                        	"type": "success"});
                    	}else{
                    	     toastEvent.setParams({
                        	"message": "Contact has been opted out of surveys",
                        	"type": "success"});
                    	}

                    	toastEvent.fire();               
            	}
            	else {
                	console.log('There was a problem during opting out');
            	}
        	});
        	$A.enqueueAction(action);
        }else{
            component.set("v.validationMessages", errorMessages);
            component.set("v.showMessages", true);
        }   
	},
	  
	getEmail  : function(component, event, helper) {
        
        var action = component.get("c.getEmail");
        action.setParams({"recordId": component.get("v.recordId")});
                
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                       	 
                component.set("v.emailAddress", response.getReturnValue());                          
            }
            else {
                console.log('There was a problem and state is: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    hasAnEmail  : function(component, event, helper) {
        
        var action = component.get("c.hasAnEmail");
        action.setParams({"recordId": component.get("v.recordId")});
                
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                       	 
                component.set("v.hasEmailAddress", response.getReturnValue());                          
            }
            else {
                console.log('There was a problem and state is: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    isOptedOut  : function(component, event, helper) {
        
        var action = component.get("c.isOptedOut");
        action.setParams({"recordId": component.get("v.recordId")});
                
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                       	 
                component.set("v.isOptedOut", response.getReturnValue());                          
            }
            else {
                console.log('There was a problem and state is: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPermission  : function(component, event, helper) {
        
        var action = component.get("c.checkPermissionSet");
                
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                       	 
                component.set("v.hasPermission", response.getReturnValue());               
            }
            else {
                console.log('There was a problem and state is: ' + state);
            }
        });
        $A.enqueueAction(action);
    }
})