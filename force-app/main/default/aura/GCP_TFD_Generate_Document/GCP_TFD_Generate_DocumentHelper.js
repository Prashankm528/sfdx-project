({
	onLoad : function(component,event) {
        //call apex class method
          var action = component.get('c.getCase');
          action.setParams({
             "caseId" : component.get("v.recordId")  
          });
          action.setCallback(this, function(response) {
          //store state of response
          var state = response.getState();
          if (state === "SUCCESS") {
              //set response value in Case attribute on component.
              var caseRec = response.getReturnValue();
              component.set("v.caseRecord", caseRec);
              //alert(caseRec);
          }
  		});
  		$A.enqueueAction(action);		
	},
    displayMessage : function(component,event) {
        var savecheckbox = component.get("c.updategeneratebutton");
        	savecheckbox.setParams({
            	"recid":component.get("v.recordId")
        	});
            var toastEvent = $A.get("e.force:showToast");
            // Toast Event to display A success Message
            toastEvent.setParams({
                
                "title": "Success!",
                
                "type": "success",
                
                "message": "Document will be generated shortly. Please allow about 20 seconds before refreshing the record."
                
            });             
            toastEvent.fire()
            $A.enqueueAction(savecheckbox);
            $A.get('e.force:refreshView').fire();
    },
    updateCase : function(component,event) {
        //call apex class method
        //alert('Calling');
          component.set("v.isOpen", false);
          var action = component.get('c.updateisgenericfield');
          action.setParams({
             "recid" : component.get("v.recordId"),
              "isGeneric" : component.get("v.genericTemplate")
          });
          action.setCallback(this, function(response) {
          //store state of response
          var state = response.getState();
          if (state === "SUCCESS") {
              //No logic needed in callback method...
          }
  		});
  		$A.enqueueAction(action);		
	}
})