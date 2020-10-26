({
    init: function (cmp, event, helper) {
        // Get the list value from Account
        var action = cmp.get("c.getValues");
        
        // Create a callback that is executed after 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                cmp.set("v.options",response.getReturnValue());
                console.log(cmp.get('v.options'));
                
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log('errors are--'+errors);
                }
        });
        $A.enqueueAction(action);
    },
    
    onbuttonclick : function(component){
        var selValue = component.get("v.selectedValue");
        console.log('inside button click--'+selValue);
        var appEvent = $A.get("e.c:ICRM_CreditFireEvent");
        appEvent.setParams({
            "CPID" : selValue,
            "recId" : component.get("v.recordId")
            });
        appEvent.fire();
    }
    ,
    
    onbuttonclick1 : function(component){
        var selValue = component.get("v.selectedValue");
        console.log('inside button click--'+selValue);
        var appEvent = $A.get("e.c:ICRM_CreditFireEvent");
        appEvent.setParams({
            "CPID" : selValue,
            "recId" : component.get("v.HoldRecordId.Id")
            });

        appEvent.fire();
    }
});