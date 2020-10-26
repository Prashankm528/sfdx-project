({
    doInit : function(component, event, helper) {
        var getStage = component.get("c.getStage");
        getStage.setParams({"opportunityId": component.get("v.recordId")});

        // To set Opportunity Stage...
        getStage.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.oppoStage", response.getReturnValue());
            } else {
                console.log('Problem getting opportunity stage: ' + state);
            }
        });
        $A.enqueueAction(getStage);

        var getCommit = component.get("c.getCommit");
        getCommit.setParams({"opportunityId": component.get("v.recordId")});

        // To set Opportunity isCommit...
        getCommit.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.isCommit", response.getReturnValue());
            } else {
                console.log('Problem getting opportunity stage: ' + state);
            }
        });
        $A.enqueueAction(getCommit);

        var getOpportunity = component.get("c.getOpportunity");
        getOpportunity.setParams({"opportunityId": component.get("v.recordId")});

        // To set Opportunity Name...
        getOpportunity.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") { 
                component.set("v.opportunity", response.getReturnValue());
            } else {
                console.log('Problem getting opportunity name: ' + state);
            }
        });
        $A.enqueueAction(getOpportunity);

        // Are there already some revenues instead of Estimate set?
        var hasRevenues = component.get("c.hasRevenues");
        hasRevenues.setParams({"opportunityId": component.get("v.recordId")});

        hasRevenues.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                component.set("v.hasRevenues", retVal);
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(hasRevenues);

        var getEstimate = component.get("c.getEstimate");
        getEstimate.setParams({"opportunityId": component.get("v.recordId")});

        getEstimate.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                if (retVal != null) {
                    component.set("v.type", retVal.Type);
                    component.set("v.revenue", retVal.Revenue__c);
                    component.set("v.margin", retVal.Margin__c);
                    component.set("v.volume", retVal.Volume__c);
                } else {
                    
                }
            } else {
                console.log('Could not get estimate: ' + state);
            }
        });
        $A.enqueueAction(getEstimate);

        var getShowSellOut = component.get("c.getShowSellOut");

        getShowSellOut.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                console.log('Setting v.showSellOut to: ' + retVal);
                component.set("v.showSellOut", retVal);
            } else {
                console.log('Could not get showSellOut: ' + state);
            }
        });
        $A.enqueueAction(getShowSellOut);
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSave : function(component, event, helper) {
        var negativeFields = new Array();
        var message = '';
        var i;
        event.stopPropagation();

        var stage = component.get('v.oppoStage');
        var id = component.get('v.recordId');
        var type = component.get('v.type');
        var revenue = component.get('v.revenue');
        var margin = component.get('v.margin');
        var volume = component.get('v.volume');

        if (!stage) {
            $A.get("e.force:closeQuickAction").fire();
        }

        // Values check
        if (revenue < 0 || revenue == null || revenue == undefined) {
            negativeFields.push('Revenue ');
        }

        if (margin < 0 || margin == null || margin == undefined) {
            negativeFields.push('Margin ');
        }

        if (volume < 0 || volume == null || volume == undefined) {
            negativeFields.push('Volume ');
        }

        //Message generation
        if (negativeFields.length > 0) {
            message += 'The Total ';
            for (i = 0; i < negativeFields.length; i++) {
                message += negativeFields[i];
            }
            message += 'can not be a blank or negative value.';
        }

        if (message.length > 1) {
            component.set('v.hasErrors', true);
            component.set('v.errorMessage', message);
            return;
        }

        //Setting up values for Estimate Revenue
        var saveEstimate = component.get("c.saveEstimate");
        saveEstimate.setParams({
            "opportunityId": id,
            "typeVal": type,
            "revenueVal": revenue,
            "marginVal": margin,
            "volumeVal": volume
        });

        saveEstimate.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                if (retVal == 'SUCCESS') {

                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "The record has been updated successfully."
                    });
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire();
                } else {
                    component.set('v.hasErrors', true);
                    component.set('v.errorMessage', retVal);
                    return;
                }
            } else {
                component.set('v.hasErrors', true);
                component.set('v.errorMessage', errorMessage);
                return;
            }
        });
        $A.enqueueAction(saveEstimate);
    }
})