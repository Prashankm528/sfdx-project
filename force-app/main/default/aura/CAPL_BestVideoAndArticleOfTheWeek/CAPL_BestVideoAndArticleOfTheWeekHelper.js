({
	fetchVideoOfTheWeek : function(component) {
		var action = component.get("c.fetchBestVideo");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var video = response.getReturnValue();

            	//video.CAPL_Title__c = video.CAPL_Title__c.substring(0, 150) + '...'; 
            	
            	component.set("v.video", video);
            } 
        });
        $A.enqueueAction(action);
	}, 

	fetchArticleOfTheWeek : function(component) {
		var action = component.get("c.fetchBestArticle");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var article = response.getReturnValue();

            	//article.Title = article.Title.substring(0, 150) + '...'; 
            	
            	component.set("v.article", article);
            } 
        });
        $A.enqueueAction(action);
	}
})