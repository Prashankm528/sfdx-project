({
	doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        if(accountId !=null && accountId!=undefined) {
            var ciAction = component.get("c.getConsumerDetails");
            ciAction.setParams({
                "accountId": accountId
            });
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.lookupInfo", a.getReturnValue());
                    component.set("v.showDetails", true);
                } else if (state == "ERROR") {
                    component.set("v.errorMessage", a.getError()[0].message);
                }
                helper.toggleSpinner(component,event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.lookupInfo", []);
            helper.toggleSpinner(component,event);
        }        
    },
})