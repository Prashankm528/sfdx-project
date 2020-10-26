({
	fetchCurrentUserId : function(component, event) {
		var action = component.get("c.fetchUserId");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var currentUserId = response.getReturnValue();
            	var userId = component.get("v.recordId");

            	console.log('currentUserId -> ' +currentUserId);
            	console.log('userId -> ' + userId);


            	if (currentUserId.includes(userId)) {
            		component.set("v.isShowSection", true);
            	}
            } 
        });
        $A.enqueueAction(action);
	},

	fetchUserEmailNotifications : function(component, event) {
		var action = component.get("c.fetchEmailNotifications");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var member = response.getReturnValue();

            	component.set("v.member", member);
            } 
        });
        $A.enqueueAction(action);
	}
})