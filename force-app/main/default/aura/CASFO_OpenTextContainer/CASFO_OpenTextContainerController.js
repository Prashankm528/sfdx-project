({  
    checkAccSalesOrg: function(component, event, helper) {
    	var action = component.get("c.isOpenTextPilotCountry");
        action.setParams({salesOrg : component.get("v.accountFields.Sales_Organisation__c")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isValidSalesOrg = response.getReturnValue();
                component.set("v.isValidSalesOrg", isValidSalesOrg);
                if (isValidSalesOrg) {
                 	helper.setErpId(component);
                } else {
                    component.set("v.errorMsg", $A.get("$Label.c.SFO_OpenText_Pilot_ErrMsg"));
                }
            }
        });
        
        $A.enqueueAction(action);
    }
})