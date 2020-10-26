({
	isUserLikedRecord : function(component, recordId) {
        var action = component.get("c.isLikedRecord");

        action.setParams({"recordId": recordId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isLiked = response.getReturnValue();

                component.set("v.isLiked", isLiked);
            }
        });
        $A.enqueueAction(action);
    },

    fetchNumOfLikes : function(component, recordId) {
        var action = component.get("c.fetchNumberOfLikes");

        action.setParams({"recordId": recordId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var likes = response.getReturnValue();

                component.set("v.numOfLikes", likes);
            }
        });
        $A.enqueueAction(action);
    }
})