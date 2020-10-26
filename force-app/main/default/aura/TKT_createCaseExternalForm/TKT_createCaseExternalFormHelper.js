({
    handleErrors: function(response) {
        const errors = response.getError();
        const toastParams = {
            title: "Error",
            message: "Unknown error",
            type: "error"
        };
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },

	getOptions: function(component) {
        const getOptions = component.get("c.getHelpOptions");
        getOptions.setParams({field: "TKT_How_can_we_help_you_EXTERNAL_FORM__c"});
        getOptions.setCallback(this, function(response){
            //$A.util.addClass(component.find("loadingSpinner"), "slds-hide");
            const state = response.getState();
            if(state === "SUCCESS") {
                const result = response.getReturnValue();
                component.set("v.helpOptions", result);	

            } else {
                helper.handleErrors(response);
            }
        });
        $A.enqueueAction(getOptions);
    },

	getBusinessOptions: function(component) {
        const getOptions = component.get("c.getBusinessOptions");

        getOptions.setCallback(this, function(response){
            //$A.util.addClass(component.find("loadingSpinner"), "slds-hide");
            const state = response.getState();
            if(state === "SUCCESS") {
                const result = response.getReturnValue();
                component.set("v.businessOptions", result);	

            } else {
                helper.handleErrors(response);
            }
        });
        $A.enqueueAction(getOptions);
    },

    insertCase: function(component, Case) {
        const action = component.get("c.saveCase");
        action.setParams({newCase: Case});

        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === "SUCCESS") {
                const result = response.getReturnValue();
                component.set("v.caseId", result.Id);
                component.set("v.caseNumber", result.CaseNumber);

                this.findCaseNumber(component);
            } else {
                helper.handleErrors(response);
            }
        });
    $A.enqueueAction(action);
    },

    findCaseNumber: function(component, case_Id) {
        const action = component.get("c.getCaseNumber");
        action.setParams({caseId : component.get("v.caseId")});
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const result = response.getReturnValue();
                component.set("v.caseNumber", result);
            } else {
                helper.handleErrors(response);
            }
        });
    $A.enqueueAction(action);
    },

    alertInvalidFields : function(component, event, helper) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: 'Please review the required fields',
            type: 'error',
        });
        toastEvent.fire();
    }


})