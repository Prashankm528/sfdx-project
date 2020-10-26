({
	createRecord : function(component, event) {
		var action = component.get('c.createDocumentRequest');
        var recId = component.get("v.recordId");

        action.setParams({
            'requestId': recId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){ 
                var resultId = response.getReturnValue();
                if(resultId!=null && resultId!='' && resultId!=undefined){
                    window.location.replace('/'+resultId);
                }
            }
            else {
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(action);
	},
    
    getRequestStatus : function(component, event) {
		var action = component.get("c.getStatus");
        var recId = component.get("v.recordId");
        
        action.setParams({
            "docRequestId": recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === 'SUCCESS'){
                component.set("v.status",response.getReturnValue());
            } else {
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(action);
	}
})