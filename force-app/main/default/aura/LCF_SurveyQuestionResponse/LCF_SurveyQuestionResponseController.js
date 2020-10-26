({
    
    doInit : function(component, event, helper) {
        var action = component.get("c.getSurveyQuestions");
        action.setParams({surveyId : component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS') {
                component.set("v.surveys", response.getReturnValue());
            } else {
                console.log("Error retrieving data: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    gotoRelatedList : function (component, event, helper) {
    var relatedListEvent = $A.get("e.force:navigateToRelatedList");
    relatedListEvent.setParams({
        "relatedListId": "Survey_Question_Answers__r",
        "parentRecordId": component.get("v.recordId")
    	});
    relatedListEvent.fire();
	}
})