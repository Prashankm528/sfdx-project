({
callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());
                
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var errorEvent = component.getEvent("onNotification");
                    errorEvent.setParams({
                        config: {
                            title: 'Error',
                            message: errors[0].message,
                            variant: 'error',
                            mode:'sticky'
                        }   
                    });
                    errorEvent.fire();
                } else {
                    throw new Error("Unknown Error");
                }
            }
            
        });
        $A.enqueueAction(action);   
    }
})