({
	doInit : function(component, event, helper) {
		var getUserId = component.get("c.fetchUserId");
        getUserId.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var userId = response.getReturnValue();
            	console.log("userId: " + userId);
                if(userId != null)
	            	component.set("v.userId", userId);
	        }
	        else {
	            console.log("Failed with state: " + state);
	        } 
        });
        $A.enqueueAction(getUserId);

        var getUserName = component.get("c.fetchUserName");
        getUserName.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var userName = response.getReturnValue();
            	console.log("userName: " + userName);
                if(userName != null)
	            	component.set("v.userName", userName);
	        }
	        else {
	            console.log("Failed with state: " + state);
	        }  
        });
        $A.enqueueAction(getUserName);

        var getHomeUrl = component.get("c.fetchCommunityHomeUrl");
        getHomeUrl.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var homeUrl = response.getReturnValue();
            	console.log("homeUrl: " + homeUrl);
                if(homeUrl != null) {
	            	component.set("v.communityHome", homeUrl);
	            	var logoutUrl = homeUrl;
	            	if (logoutUrl.indexOf('/s/') > 0) {
	            		logoutUrl = logoutUrl.replace('/s/', '');
	            	}
	            	component.set("v.communityLogout", logoutUrl);
                }
	        }
	        else {
	            console.log("Failed with state: " + state);
	        }  
        });
        $A.enqueueAction(getHomeUrl);

        var sendEmail = component.get("c.sendActivationEmail");
        sendEmail.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Email was sent.");
            }
            else {
                console.log("Failed with state: " + state);
            }  
        });
        $A.enqueueAction(sendEmail);
	},
})