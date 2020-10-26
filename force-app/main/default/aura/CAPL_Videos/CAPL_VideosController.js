({
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchVideos");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var videoList = response.getReturnValue();

            	videoList.forEach(function(el){
				    
				    console.log('! -> ' + new Date(el.CreatedDate).getTime());
				    var createdDate = new Date(el.CreatedDate).getTime();
	                el.CreatedDate = createdDate;
	                
                    el.RelativeTime = helper.timeDifference(component, Date.now(), createdDate);
				});
            	
                component.set("v.videoList", videoList);
            }
        });
        $A.enqueueAction(action);
    },

    goToDetailPage : function(component, event, helper) {
		var videoId = event.target.id;

		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": videoId
        });
        navEvt.fire();
	}
})