({

    doInit : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "DUP_List_Of_Values__c",
            "defaultFieldValues": {
                'DUP_Options__c' : 'Optional'
                
            }
        });
        createRecordEvent.fire();
    }
});