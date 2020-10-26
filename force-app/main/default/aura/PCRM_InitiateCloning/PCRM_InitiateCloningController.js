({
    handleClick : function (cmp, event, helper) 
    {
      cmp.set('v.showSpinner',true);    
        
     //alert('recIdL'+ cmp.get("v.recordId"));   
     var action = cmp.get("c.initiateCloning");
       action.setParams({ 
                           varOpportunityId : cmp.get("v.recordId")
                        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response)
        {
           var state = response.getState();
           // alert('state11: '+state); 
            
           if (state === "SUCCESS")
           {
               cmp.set('v.showSpinner',false); 
               
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
               
               // alert("You clicked: " + event.getSource().get("v.label"));
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                   "title": "Success!",
                   "message": "Successfully Renewed Contract !!!",
                   "type" : "success"
               });
               toastEvent.fire();
           }
            else if (state === "INCOMPLETE") 
            {
               cmp.set('v.showSpinner',false);   
               
               // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
            }
            else if (state === "ERROR")
            {
                cmp.set("v.showSpinner", false); 
                
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                var errors = response.getError();
                if (errors)
                {
                    if (errors[0] && errors[0].message)
                    {
                         var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "error!",
                                "message": errors[0].message,
                                "type" : "error"
                            });
                            toastEvent.fire();
                    }
                } else 
                {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
       
    }
});