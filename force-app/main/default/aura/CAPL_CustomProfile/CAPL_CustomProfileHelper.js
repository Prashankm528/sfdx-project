({
	isUserInOwnPage : function(component, event) {
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

	getuserPhoto : function(component, event) {
		var action = component.get("c.fetchUserProfilePhoto");

		var userId = component.get("v.recordId");

		action.setParams({"userId" : userId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var photoURL = response.getReturnValue();

                component.set("v.userProfilePhoto", photoURL);
            }
        });
        $A.enqueueAction(action);
	}, 

	getUserChatterActivity : function(component, event) {
		var action = component.get("c.fetchUserChatterActivity");

		var userId = component.get("v.recordId");

		action.setParams({"userId" : userId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var chatterActivity = response.getReturnValue();
 
                if (chatterActivity != null && 
                    (
                        chatterActivity.InfluenceRawRank == undefined 
                        || chatterActivity.PostCount == undefined
                        || chatterActivity.CommentReceivedCount == undefined
                        || chatterActivity.CommentCount == undefined
                        || chatterActivity.LikeReceivedCount == undefined
                    )
                ) {
                    chatterActivity.InfluenceRawRank = '000';
                    chatterActivity.PostCount = '000';
                    chatterActivity.CommentReceivedCount = '000';
                    chatterActivity.CommentCount = '000';
                    chatterActivity.LikeReceivedCount = '000';
                } else {
                    chatterActivity.InfluenceRawRank = this.addZeroesToNumber(chatterActivity.InfluenceRawRank);
                    chatterActivity.PostCount = this.addZeroesToNumber(chatterActivity.PostCount);
                    chatterActivity.CommentReceivedCount = this.addZeroesToNumber(chatterActivity.CommentReceivedCount);
                    chatterActivity.CommentCount = this.addZeroesToNumber(chatterActivity.CommentCount);
                    chatterActivity.LikeReceivedCount = this.addZeroesToNumber(chatterActivity.LikeReceivedCount);
                }

                component.set("v.userChatterActivity", chatterActivity);
            }
        });
        $A.enqueueAction(action);
	}, 


	getUserReputation : function(component, event) {
		var action = component.get("c.fetchUserReputation");

		var userId = component.get("v.recordId");

		action.setParams({"userId" : userId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userReputation = response.getReturnValue();

                component.set("v.userReputation", userReputation);
            }
        });
        $A.enqueueAction(action);
	}, 

	getUserInformation : function(component, event) {
		var action = component.get("c.fetchUserInfo");

		var userId = component.get("v.recordId");

		action.setParams({"userId" : userId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userInfo = response.getReturnValue();

                component.set("v.userInfo", userInfo);
            }
        });
        $A.enqueueAction(action);
	}, 

	getUserFollowers : function(component, event) {
		var action = component.get("c.fetchUserFollowers");

		var userId = component.get("v.recordId");

		action.setParams({"userId" : userId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var numOfUserFollowers = response.getReturnValue();

                console.log('numOfUserFollowers -> ' + numOfUserFollowers);

                numOfUserFollowers = this.addZeroesToNumber(numOfUserFollowers);

                component.set("v.numOfUserFollowers", numOfUserFollowers);
            }
        });
        $A.enqueueAction(action);
	}, 

	getOEMBrandValues : function(component, event) {
		var action = component.get("c.fetchOEMBrandValues");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var values = response.getReturnValue();

                component.set("v.OEMBrandValues", values);
            }
        });
        $A.enqueueAction(action);
	}, 

	addZeroesToNumber : function(n) {
		var len = 3 - (''+n).length;
		return (len > 0 ? new Array(++len).join('0') : '') + n
	}
})