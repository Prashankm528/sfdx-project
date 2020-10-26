({ 
	doInit : function(component, event, helper) {
		var action = component.get("c.fetchRecordTypeName");

        var videoId = component.get("v.recordId");

        console.log('videoId -> ' + videoId);

        action.setParams({"videoId": videoId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var recordTypeName = response.getReturnValue();

                if (recordTypeName == 'Upload new video') {
                    helper.fetchVideoDetails(component,videoId);
                    helper.fetchAttachedDocumentId(component,videoId);

                    component.set("v.isNewVideo", true);
                } else 
                if (recordTypeName == 'Use link to existing video') {
                    helper.fetchVideoDetails(component,videoId);

                    component.set("v.isNewVideo", false);
                }
            }
        });
        $A.enqueueAction(action);
    }
})