({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchArticles");

        var topicId = component.get("v.recordId");

        action.setParams({"topicId": topicId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var articleList = response.getReturnValue();

                articleList.forEach(function(el){
                    var createdDate = new Date(el.LastPublishedDate).getTime();
                    el.LastPublishedDate = createdDate;
                });

                component.set("v.articleList", articleList);
            }
        });
        $A.enqueueAction(action);
    },

    goToDetailPage : function(component, event, helper) {
        var articleId = event.target.id;

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": articleId
        });
        navEvt.fire();
    }
})