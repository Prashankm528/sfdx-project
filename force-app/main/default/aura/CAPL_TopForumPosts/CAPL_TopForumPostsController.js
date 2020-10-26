({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchForumPosts");

        action.setCallback(this, function(response) {
            var state = response.getState();

            console.log('state -> ' + state);

            if (state === "SUCCESS") {
                var forumPosts = response.getReturnValue();

                forumPosts.forEach(function(el){
                    var createdDate = new Date(el.post.CreatedDate).getTime();
                    el.post.CreatedDate = createdDate;

                    el.post.RelativeTime = helper.timeDifference(component, Date.now(), createdDate);

                    console.log('post -> ' + el);
                });

                component.set("v.forumPosts", forumPosts);
            }
        });
        $A.enqueueAction(action);
    },

    goToDetailPage : function(component, event, helper) {
        var forumPostId = event.currentTarget.id;
 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": forumPostId
        });
        navEvt.fire();
    }
})