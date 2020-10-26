({
    doInit: function(component, event, helper) {
        var accountId = component.get("v.recordId");
        if(accountId != null && accountId != undefined) {
           var ciAction = component.get("c.getUserSecurityQuestions");
            ciAction.setParams({
                "accountId": accountId
            });
            
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.newQuestions", a.getReturnValue().questions);
                } else if (state == "ERROR") {                    
                    helper.toast(component, a.getError()[0].message, 'error');
                }
                helper.toggleSpinner(component, event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.newQuestions", []);
            helper.toggleSpinner(component, event);
        }        
    },
    
    editQuestions: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var available = component.get("v.availableQuestions");
        var ed = component.get("v.editing");
        if(component.get("v.availableQuestions") != null) {
            component.set("v.editing", !ed);
        }
        var accountId = component.get("v.recordId");
        if(accountId != null && accountId != undefined) {
            var ciAction = component.get("c.getAvailableSecurityQuestions");
            ciAction.setParams({
                "accountId": accountId
            });
            
            
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.availableQuestions", a.getReturnValue());
                    component.set("v.editing", true);
                } else if (state == "ERROR") {
                    helper.toast(component, a.getError()[0].message, 'error');
                }
                helper.toggleSpinner(component,event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.newQuestions", []);
            helper.toggleSpinner(component,event);
        }        
    },
    
    submitQuestions : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        var oq = component.get("v.newQuestions");
        if(accountId != null && accountId != undefined) {
            var ciAction = component.get("c.submitNewSecurityQuestions");
            ciAction.setParams({
                "accountId": accountId,
                "questions": JSON.stringify(oq)
            });
            
            
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    if(a.getReturnValue()) {
                        helper.toast(component, "Security questions successefully changed!",  'success');
                        $A.get('e.force:refreshView').fire();
                        component.set("v.editing", false);
                    } else {
                        helper.toast(component, "Error while trying to submit questions", 'error');
                        helper.toggleSpinner(component, event);
                    }
                } else if (state == "ERROR") {
                    helper.toast(component, a.getError()[0].message, 'error');
                    helper.toggleSpinner(component, event);
                }
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.newQuestions", []);
            helper.toggleSpinner(component,event);
        }        
    },
    
    cancelSubmit : function(component, event, helper) {
        component.set("v.editing", false);
        $A.get('e.force:refreshView').fire();
        helper.toggleSpinner(component,event);
    },
    
    authenticateQuestions : function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        var oq = component.get("v.newQuestions");
        if(accountId != null && accountId != undefined) {
            var ciAction = component.get("c.authenticateSecurityQuestions");
            ciAction.setParams({
                "accountId": accountId,
                "questions": JSON.stringify(oq)
            });
            
            
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    if(a.getReturnValue()) {
                        helper.toast(component, "Security questions validated!", 'success');
                        $A.get('e.force:refreshView').fire();
                        component.set("v.editing", false);
                    } else {
                        helper.toast(component, "Error while trying to validate questions", 'error');
                        helper.toggleSpinner(component, event);
                    }
                } else if (state == "ERROR") {
                    helper.toast(component, a.getError()[0].message, 'error');
                    helper.toggleSpinner(component, event);
                }
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.newQuestions", []);
            helper.toggleSpinner(component,event);
        }        
    },
})