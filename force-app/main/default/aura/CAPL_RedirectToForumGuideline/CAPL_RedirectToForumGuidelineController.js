({
	doInit : function(component, event, helper) {
		var action = component.get("c.redirectToForumGuideline");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var isRedirect = response.getReturnValue(); 
            	console.log(isRedirect);

            	if (isRedirect == true) {
            		console.log('1');

				    var urlEvent = $A.get("e.force:navigateToURL");
				    urlEvent.setParams({
				      "url": "/forumguideline"
				    });
				    urlEvent.fire();
            	}
                
            } 
        });
        $A.enqueueAction(action);
	}
})