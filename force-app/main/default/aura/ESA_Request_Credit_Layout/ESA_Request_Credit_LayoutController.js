({
    
    handleOnload : function(component, event, helper){
        var recUi = event.getParam('recordUi');        
        var relation = recUi.record.fields['ESA_Relationship_Type__c'].value;
        var relation1 = recUi.record.fields['ESA_Custom_permission__c'].value;        
        component.set('v.retype', relation);          
        if(relation1 == true)
        {
            component.set('v.flag1',false);
            //relation1 = false;
        }
        else{
            component.set('v.flag1',true);
        }
        
        
    },
    
    handleOnSubmit : function(component, event, helper) {
        
        event.preventDefault();//stop basic functionality
        var fieldevent = event.getParam('fields');
        fieldevent['OLCM_Credit_Request_Check__c'] = true;
        component.find("myForm").submit(fieldevent);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Credit Request has been sent successfully."
        });
        toastEvent.fire();	 
        
    },
    
    handleSuccess : function(component, event, helper){                              
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
        
    },
    
    onError : function(component, event, helper) {
        var errors = event.getParams();
        console.log("Error Response", JSON.stringify(errors));
        var errormsg = JSON.stringify(errors);
        if($A.util.isEmpty(errormsg)) {           
            component.set("v.errormsg", false);
        }
        else{
            component.set("v.errormsg", true);                        
        }
        
    }
    
})