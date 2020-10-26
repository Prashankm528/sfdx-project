({
	callApexMethodOc : function(component,event) {
		var action = component.get('c.updaterunupdatetrigger');
          action.setParams({
             "ocid" : component.get("v.recordId")  
          });
          action.setCallback(this, function(response) { 
           //store state of response
          var state = response.getState();
          if (state === "SUCCESS") {
              var spinner = component.find("mySpinner");
        	  $A.util.addClass(spinner, "slds-hide");		
              //Show success message...
              var toastEvent = $A.get("e.force:showToast");
              //Toast Event to display A success Message
              toastEvent.setParams({
                
                "title": "Success!",
                
                "type": "success",
                
                "message": "Data Linkage Successfull"
                
              });             
              toastEvent.fire();
              $A.get('e.force:refreshView').fire();
          }
  		});
  		$A.enqueueAction(action);
	},
    callApexMethodLc : function(component,event) {
		var action = component.get('c.updaterunupdatetriggerlc');
          action.setParams({
             "lcid" : component.get("v.recordId")  
          });
          action.setCallback(this, function(response) { 
           //store state of response
          var state = response.getState();
          if (state === "SUCCESS") {
              var spinner = component.find("mySpinner");
        	  $A.util.addClass(spinner, "slds-hide");		
              //Show success message...
              var toastEvent = $A.get("e.force:showToast");
              //Toast Event to display A success Message
              toastEvent.setParams({
                
                "title": "Success!",
                
                "type": "success",
                
                "message": "Data Linkage Successfull"
                
              });             
              toastEvent.fire();
              $A.get('e.force:refreshView').fire();
          }
  		});
  		$A.enqueueAction(action);
	}
})