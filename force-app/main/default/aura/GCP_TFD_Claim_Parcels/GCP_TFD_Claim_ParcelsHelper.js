({
	onLoad : function(component,event) {
        //call apex class method
          var action = component.get('c.fetchParcels');
          action.setParams({
             "lcid" : component.get("v.recordId")  
          });
          action.setCallback(this, function(response) {
          //store state of response
          var state = response.getState();
          if (state === "SUCCESS") {
              //set response value in ListOfContact attribute on component.
              component.set("v.ListOfParcels", response.getReturnValue());
          }
  		});
  		$A.enqueueAction(action);		
	},
    
    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get('c.getselectOptions');
        action.setParams({
            "objObject": component.get("v.caseValue"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
 				//alert(response.getReturnValue());
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
    
    finishProcess : function(component,parId,cletter,sletter,discdate) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        //call apex class method which does the following:
        // - Create new case and associate selected parcels with Case.
        // - Update status of PArcel records.
        // - Calculate the sum of amount of selected parcels and update on Case object.
          var action = component.get('c.createCase');
          action.setParams({
             "parcelids" : parId,
             "CoverLetter" : cletter,
             "SupportingLetter" : sletter,
			 "DiscountDate" : discdate,
             "lcid" : component.get("v.recordId") 
          });
          action.setCallback(this, function(response) {
          //store state of response
          var state = response.getState();
          //If success, show a success message and navigate to Case record...
          if (state === "SUCCESS") {
              var caseId = response.getReturnValue();
              //Show a success message 
              var toastEvent = $A.get("e.force:showToast");
    		  toastEvent.setParams({
                    "type": "success",
        			"title": "Success!",
        			"message": $A.get("$Label.c.GCP_TFD_CLAIM_SUCCESS_MESSAGE")
    		  });
    		  toastEvent.fire();
              //Navigate to Case record home
              var navEvt = $A.get("e.force:navigateToSObject");
    		  navEvt.setParams({
      		  	"recordId": caseId,
    		  });
    		  navEvt.fire();
              var spinner = component.find("mySpinner");
        	  $A.util.addClass(spinner, "slds-hide");
          }
          //If error, show error message and stay on the same page...
          if (state === "ERROR") {
              //var caseId = response.getReturnValue();
              //Show a success message 
              var toastEvent = $A.get("e.force:showToast");
    		  toastEvent.setParams({
                    "type": "failure",
        			"title": "Failure!",
        			"message": $A.get("$Label.c.GCP_TFD_CLAIM_FAILURE_MESSAGE")
    		  });
    		  toastEvent.fire();
              //Navigate to LC record home
              var recId = component.get("v.recordId");
              var navEvt = $A.get("e.force:navigateToSObject");
    		  navEvt.setParams({
      		  	"recordId": recId,
    		  });
    		  navEvt.fire();
              var spinner = component.find("mySpinner");
        	  $A.util.addClass(spinner, "slds-hide");
          }
  		});
  		$A.enqueueAction(action);		
	}
})