({
	checkPermission : function(cmp, evt, hlp) {
        var action = cmp.get("c.checkPermission");
        
        action.setParams({
            "permissionName": 'DUP_SuperUser'
        }); 
        
        action.setCallback(this, function(response) {   
                var state = response.getState();
                if(state === "SUCCESS") {                
                    var result = response.getReturnValue();
                    cmp.set("v.isSuperUser" , result);
                    
                }
            });
        $A.enqueueAction(action);
    },
})