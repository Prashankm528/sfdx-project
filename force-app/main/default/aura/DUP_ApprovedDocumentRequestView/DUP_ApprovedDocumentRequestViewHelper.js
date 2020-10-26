({
    getAllDocumentStore: function(cmp, evt, hlp) {    
        var action = cmp.get("c.getDocumentStore");
        action.setParams({"docRequestId": cmp.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                cmp.set("v.projectDocument", response.getReturnValue());                
                cmp.set("v.documents",response.getReturnValue()); 
            } else {
                console.log('Problem getting document Store, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },

   sendAllFilesToSP : function(cmp, evt, hlp) {
        cmp.set("v.isSpinner", true);
        var action = cmp.get("c.sendAllFileToSharepoint");
        var action2 = cmp.get("c.updateSharepointField");

        action.setParams({
            "docRequestId": cmp.get("v.recordId")
        }); 
        action2.setParams({
            "recordId" : cmp.get("v.recordId")
        });  

        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var urlcheck = response.getReturnValue();
                console.log("urlcheck",urlcheck);
               if(!urlcheck){
               cmp.set("v.isSpinner", false);
                   cmp.set('v.isActive', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Files already sent to sharepoint",
                    "message": "Please check individual file for status.",
                    "type" : "info"
                });
                toastEvent.fire();
            	}
                else{               
                cmp.set("v.isSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Call to sharepoint performed",
                    "message": "Please wait till process completes and check individual file for status.",
                    "type" : "info"
                });
                toastEvent.fire();
                cmp.set('v.isActive', true);
                //Added for progress bar
                var interval = setInterval($A.getCallback(function () {
                        var jobStatus = cmp.get("c.getBatchJobStatus");
                        if(jobStatus != null){
                            jobStatus.setParams({ jobID : response.getReturnValue()});
                            jobStatus.setCallback(this, function(jobStatusResponse){
                                var state = jobStatus.getState();
                                if (state === "SUCCESS"){
                                    var job = jobStatusResponse.getReturnValue();
                                    cmp.set('v.apexJob',job);
                                    var processedPercent = 0;
                                    if(job.JobItemsProcessed != 0){
                                        processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                                    }
                                    console.log('job.JobItemsProcessed / job.TotalJobItems',job.JobItemsProcessed,job.TotalJobItems);
                                    var progress = cmp.get('v.progress');
                                    if(progress == '100')
                                    {
                                        cmp.set('v.isActive', false);
                                        window.location.reload();
                                    }
                                    cmp.set('v.progress', progress === 100 ? clearInterval(interval) :  processedPercent);
                                }
                            });
				      $A.enqueueAction(jobStatus);                            
                  }
                    }), 4000);
              
                if(!cmp.get("v.isSharepointSuccess")){
                    action2.setCallback(this, function(response){
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            console.log("response>>",response);
                        cmp.set("v.isSharepointSuccess", true);
                            //window.location.reload();
                            //this.getAllDocumentStore(cmp, evt, hlp);
                        } else {
                            console.log('Problem updating field, response state: ' + state);                            
                        }
                    });
                    
                }
                $A.enqueueAction(action2); 
                
                }
            } else {
                cmp.set("v.isSpinner", false);
                console.log('Problem updating document status, response state: ' + state);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occured. Please try again or contact System Administrator."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);        
    }
})