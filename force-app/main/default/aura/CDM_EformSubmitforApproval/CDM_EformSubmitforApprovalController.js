({
    /** doInit  system event  **/
	doInit : function(component, event, helper) {
        component.set('v.validApprover',true);
     
	},
     submit:  function(component, event, helper) {
     var spinner = component.find('spinner');
           $A.util.toggleClass(spinner, 'slds-hide');

        var comments = component.get('v.comments');
        var recordId = component.get('v.recordId');
        if(!comments) {
           // alert('Enter Comments');
            return null;
        }
    
         var action = component.get('c.submitAndProcessApprovalRequest'); 
		          
            action.setParams({
                recId : recordId,
                comments :comments
              });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                      var wrp = response.getReturnValue();
                    if(wrp) {
                        if(wrp.success) {
                           
                            
                            var toastEvent = $A.get("e.force:showToast");
                            if(toastEvent) {
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "type" : "Success",
                                    "message": "The record has been submitted for Approval successfully."
                                });
                                toastEvent.fire();
                               
                            
                            }
                            setTimeout(function() {
                                // $A.get('e.force:refreshView').fire();
                                location.reload();
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                            }, 2000);
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            if(toastEvent) {
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "type" : "Error",
                                    "message": "Please Select valid approver"
                                });
                                toastEvent.fire();
                            }
                        }
                    }
                   $A.util.toggleClass(spinner, 'slds-hide'); 
                }
            });
        $A.enqueueAction(action);
        
    },
   
})