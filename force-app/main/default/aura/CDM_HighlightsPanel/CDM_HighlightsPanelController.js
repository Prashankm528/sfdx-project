({
    /** doInit  system event  **/
    doInit : function(component, event, helper) {
        var action = component.get('c.getCDMFormStatus'); 
        var recordId = component.get('v.recordId');
        action.setParams({
            recId : recordId
            
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var cdmRecord = response.getReturnValue();
                component.set('v.cdmRecord',cdmRecord.cdmRecord);
                component.set('v.recordEditAccess',cdmRecord.HasEditAccess);
                  
            }
        });
        $A.enqueueAction(action);
    },
    
    hideSubmitBtn : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var recId = event.getParam("recordId");
        var btnFlag = event.getParam("btnFlag");
      
        if(recId == recordId && (btnFlag == true || btnFlag == 'true')) 
             component.set('v.recordEditAccess' , false);
        else
            component.set('v.recordEditAccess',true);
         
    },
    closeModal : function(component, event, helper) {
        var recMadal = document.getElementById('recMadal');
        recMadal.classList.add('slds-hide');
    },
    submitForApproval : function(component, event, helper) {
        //  alert('submit for approval');
        console.log('Submitting for approval');
        var rec = component.get("v.cdmRecord");
        if(rec.CDM_Country__c == 'Switzerland' && 
           rec.CDM_Gross_Amount__c == null &&
           rec.CDM_Net_Amount__c == null){
        	var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
            	"title": "Invalid CSV Format/Required Data Missing",
            	"message":  "CSV is not in correct format or required data is missing. Please verify, delete the existing CSV and upload the CSV again.",
                "duration": "10000ms",
                "type": "error"
        	});
        	toastEvent.fire();    
        }
        else{
        	component.set('v.comments','');
        	component.set('v.validApprover',true);
        	var recMadal = document.getElementById('recMadal');
        	recMadal.classList.remove('slds-hide');    
        }
    } , 
    
      onCloneAction : function(component, event, helper) {
          var spinner = component.find("mySpinner");
          $A.util.removeClass(spinner, "slds-hide");
          var recordId = component.get('v.recordId');
          var toastEvent = $A.get("e.force:showToast");
          if(toastEvent) {
              toastEvent.setParams({
                  title: "Success!",
                  type : "Success",
                  message : "New clone record has been created successfully."
              });
              toastEvent.fire();
          }
        var action = component.get('c.cloneCdnRecords'); 
         
        action.setParams({
            recId : recordId
           
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var wrp = response.getReturnValue();
                window.location.href = "/lightning/r/CDM_Credit_Debit_Note__c/" + wrp + "/view";
                var spinner = component.find("mySpinner");
       			$A.util.addClass(spinner, "slds-hide");
            }
        });
           $A.enqueueAction(action);  
    } ,  
    submit:  function(component, event, helper) {
        
        var comments = component.get('v.comments');
        var recordId = component.get('v.recordId');
        
        if(!comments) {
            var toastEvent = $A.get("e.force:showToast");
            if(toastEvent) {
                toastEvent.setParams({
                    "title": "Please enter comments.",
                    "type" : "Warning",
                    "message": " "
                });
                toastEvent.fire();
                
                
            }
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
                                "message": wrp.success
                            });
                            toastEvent.fire();
                            
                            
                        }
                        setTimeout(function(){
                            
                            location.reload();
                            
                        }, 2000);
                    } else{
                        var toastEvent = $A.get("e.force:showToast");
                        if(toastEvent) {
                            toastEvent.setParams({
                                "title": "Approver not authorized!",
                                "type" : "Error",
                                "message": wrp.error,
                                "mode":'sticky'
                                
                                
                            });
                            toastEvent.fire();
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
        
    }    
    
})