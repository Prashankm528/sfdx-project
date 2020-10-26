({
	doInit : function(component, event, helper) {
        var action = component.get("c.fetchArticleName");

        var topicId = component.get("v.recordId");

        action.setParams({"topicId": topicId});

        console.log('topic -> ' + topicId);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var name = response.getReturnValue();
                console.log('name -> ' + name);
                component.set("v.topicName", name);
            }
        });
        $A.enqueueAction(action);
	},
})