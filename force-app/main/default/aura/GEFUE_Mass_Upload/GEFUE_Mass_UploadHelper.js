({
	checkJobStatusHelper : function(component, event, helper) {
        helper.checkJobAtInterval(component,event);
        
        var intervalValue = window.setInterval(
            $A.getCallback(function() {
                if (component.get("v.isComplete")) {
                    window.clearInterval(intervalValue);
                    component.set("v.SpinnerQueueable", false);
                    
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissible',
                        title: "Success!",
                        message: "Records have been created!",
                        type: "success"
                    });
                    toastEvent.fire();
                    
                    var allOppStagingIds = [];
                    var lstOppStaging = component.get("v.oppStagingData");
                    lstOppStaging.forEach(function(record){
                        allOppStagingIds.push(record.Id);
                    });
                    
                    
                    var action2 = component.get("c.retrievePackageId");        
                    action2.setParams({
                        "setOppStagingIds" : allOppStagingIds
                    });
                    
                    action2.setCallback(this, function(response) {
                        if (response.getState() === 'SUCCESS') {
                            var packageId = response.getReturnValue();
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": packageId,
                              "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }
                    });
                    $A.enqueueAction(action2);
                    
                } else {
                    helper.checkJobAtInterval(component,event,intervalValue);
                }
            }), 5000
		);
		
	},

    checkJobAtInterval : function (component,helper, intervalValue) {
        component.set("v.SpinnerQueueable", true);
        var intervalJobId = component.get("v.batchJobId");
        var action = component.get("c.checkJobStatus");        
        action.setParams({
            "jobId" : intervalJobId
        });
        action.setCallback(this, function(response) {
            console.log('@@# response status '+response.getReturnValue());
            if (response.getReturnValue() == 'Completed') {
                component.set("v.isComplete", true);
            }
        });
        $A.enqueueAction(action); 
    },
    
    removeSiteOpp: function (component, row) {
        var rows = component.get("v.oppStagingData");
        var rowIndex = rows.indexOf(row);
        rows.splice(rowIndex, 1);
        component.set("v.oppStagingData", rows);
    }
})