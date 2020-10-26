({
	doInit : function(component, event, helper) {

        var recordId = component.get("v.recordId");

        console.log('recordId -> ' + recordId);

        helper.fetchNumOfLikes(component, recordId);
        helper.isUserLikedRecord(component, recordId);
            
    },

    voteForRecord : function(component, event, helper) {
        var action = component.get("c.likeRecord");

        var recordId = component.get("v.recordId");

        action.setParams({"recordId": recordId});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('liked');
                
                helper.isUserLikedRecord(component, recordId);
                helper.fetchNumOfLikes(component, recordId);
                
            }
        });
        $A.enqueueAction(action);
    }
})