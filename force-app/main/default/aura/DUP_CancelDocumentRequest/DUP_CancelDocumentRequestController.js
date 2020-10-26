({	init : function(component, event) {
    var action = component.get("c.getStatus");
    
    action.setParams({
        "docRequestId": component.get("v.recordId")
    });
    action.setCallback(this, function(response) {
        var state = response.getState(); 
        if (state === 'SUCCESS'){
            component.set("v.status",response.getReturnValue());
            
            
        } else {
            //do something
        }
    });
    $A.enqueueAction(action);
},
  handleSubmit : function(component, event, helper) {
      var action = component.get("c.cancelRequest");
      action.setParams({
          "docRequestId": component.get("v.recordId")
      });
      
      action.setCallback(this, function(response) {
          var state = response.getState(); 
          if (state === 'SUCCESS'){
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  "type":"success",
                  "title": "Success!",
                  "message": "Request Cancelled successfully."
              });
              toastEvent.fire();
              $A.get('e.force:refreshView').fire();
              var evt = $A.get("e.c:DUP_DisablePathButton");
              evt.setParams({
                  'status' : 'DUP_Cancelled'
              });
              evt.fire();
              
          } else {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  "type":"error",
                  "title": "Error!",
                  "message": "You encountered some errors when trying to save this record.Please contact your administrator."
              });
              toastEvent.fire();
          }
          $A.get("e.force:closeQuickAction").fire(); 
      });
      $A.enqueueAction(action);
  },
  
  handleClose : function(component, event, helper) {
      $A.get("e.force:closeQuickAction").fire(); 
  }
 })