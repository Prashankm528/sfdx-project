({
    
	fetchAdviceOfTheWeek : function(component) {
		var action = component.get("c.fetchBestComment");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var advice = response.getReturnValue(); 

                console.log('advice->' + advice.commentBody);
            	
            	component.set("v.advice", advice);
            } 
        });
        $A.enqueueAction(action);
	}, 

	fetchAdviceBackgroud : function(component) {
		var action = component.get("c.fetchBestCommentBackground");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var background = response.getReturnValue();
            	
            	component.set("v.background", background);
            } 
        });
        $A.enqueueAction(action);
	}
})