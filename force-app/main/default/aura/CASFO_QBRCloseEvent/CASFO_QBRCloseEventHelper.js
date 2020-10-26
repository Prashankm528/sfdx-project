({
	init : function(component) {
		var getEvent = component.get('c.getEvent');
               
        getEvent.setParams({
            "recordId": component.get('v.recordId')
        });
        
        getEvent.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.event", returnValue);
                    
                    // Set initial status
                    if (returnValue.Type != "Quarterly Business Review") {
                        component.set("v.state", 1);
                    } else if (returnValue.CASFO_QBR_Closed__c) {
                        component.set("v.state", 2);
                    } else if (returnValue.CASFO_QBR_Meeting_Status__c &&
                               returnValue.CASFO_QBR_Meeting_Status__c == 'Cancelled') {
                        component.set("v.state", 4);
                    } else {
                        component.set("v.state", 3);
                    }
                }
            }
        });
        
        $A.enqueueAction(getEvent);
        
        var getContacts = component.get('c.getContacts');
               
        getContacts.setParams({
            "recordId": component.get('v.recordId')
        });
        
        getContacts.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.contacts", returnValue);
                }
            }
        });
        
        $A.enqueueAction(getContacts);
	},
    
    save : function(component) {
        var contacts = component.get('v.contacts');
        var event = component.get('v.event');
        var state = component.get('v.state');
        var updateEvent = component.get('c.updateEvent');
        
        // Close
        if (state == 5 || state == 4 || (state == 3 && contacts && contacts.length == 0)) {
            event.CASFO_QBR_Closed__c = true;
            
            if (event.CALCF_QBR_Sales_Q_Not_Filled_Reason__c &&
                event.CALCF_QBR_Sales_Q_Not_Filled_Reason__c.length > 0) {
            	event.CALCF_QBR_Sales_Questions_Filled__c = false;
        	}
            
            if (state == 4) {
                event.CASFO_QBR_Meeting_Status__c = 'Cancelled';
            } else {
                event.CASFO_QBR_Meeting_Status__c = 'Completed';
            }
            
            updateEvent.setParams({
                "e": event,
            });
            
            updateEvent.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": $A.get("$Label.c.CALCF_QBR_ClosingSuccess")
                    });
                    
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire();
                }
            });
            
            $A.enqueueAction(updateEvent);
        } else {
            let button = component.find('closeButton');
    		button.set('v.label', 'Confirm and Close');
            component.set("v.state", 5);
        }
    },
    
    setRadioButtons : function(component, enabled) {
            let radioButtons = component.find('radio');
            for (var i = 0; i < radioButtons.length; i++) {
                radioButtons[i].set("v.disabled", !enabled);
    		}
    },
    
    reason : function(component) {
        var noAnswerReason = component.get("v.event.CALCF_QBR_Sales_Q_Not_Filled_Reason__c");
        var nps = component.get("v.NPSSet");
        var ces = component.get("v.CESSet");
        
        if (noAnswerReason.length > 0) {
            let button = component.find('closeButton');
                
    		button.set('v.disabled', false);
            this.setRadioButtons(component, false);
        } else { 
            if(!nps || !ces) {
                let button = component.find('closeButton');
    			button.set('v.disabled', true);
            }
            this.setRadioButtons(component, true);
        }
    },
    
    radioCES : function(component, event) {
        var value = event.getSource().get("v.value");
        var nps = component.get("v.NPSSet");
        
        component.set("v.CESSet", true);
        component.set("v.event.CALCF_QBR_Sales_CES__c", value);
        
        if(nps) {
            let button = component.find('closeButton');
    		button.set('v.disabled', false);
        }
    },
    
    radioNPS : function(component, event) {
    	var value = event.getSource().get("v.value");
        var ces = component.get("v.CESSet");
        
        component.set("v.NPSSet", true);
        component.set("v.event.CALCF_QBR_Sales_NPS__c", value);

        if(ces) {
            let button = component.find('closeButton');
    		button.set('v.disabled', false);
        }
    },
    
    onStatusPicklist : function(component) {
        var event = component.get("v.event");
        
        if (event.CASFO_QBR_Meeting_Status__c == 'Cancelled') {
                        let button = component.find('closeButton');
    					button.set('v.disabled', false);
            			component.set("v.state", 4);
        } else {
            let button = component.find('closeButton');
    		button.set('v.disabled', true);
            component.set("v.state", 3);
        }
    }
})