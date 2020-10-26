({
    helperMethod : function(component, event) {
        var action;
        var objName = component.get("v.sObjectName");
        if(objName =='Account'){
            action = component.get("c.getAccountRelatedOpportunities");
            action.setParams({'recId': component.get("v.recordId")});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('SUCCESS');
                    var storeResponse = response.getReturnValue();
                    if(storeResponse){
                        component.set("v.opportunityList", storeResponse);
                        component.set("v.relatedOpportunities", true);
                    }
                    else{
                        console.log('No opportunity exists');
                    }
                }
                else{
                    console.log('FAILURE');
                }
            });
        }
        
        $A.enqueueAction(action);
    }
})