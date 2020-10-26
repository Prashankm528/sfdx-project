({
    init : function(component, event, helper) {
        
        var getUserAction = component.get("c.getUser");
        getUserAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                component.set("v.userId", rtnValue.Id);
                component.set("v.userName", rtnValue.Name);
            }
        });
        $A.enqueueAction(getUserAction);
        
    },
    
    handleChangePassword : function(component, event, helper) {
        var modalBody;
        $A.createComponents([
            ["c:REIDP_modalBody",{}],
        ],
                            function(components, status) { 
                                if (status === "SUCCESS") {
                                    modalBody = components[0];
                                    component.find('overlayLib').showCustomModal({
                                        header: $A.get("$Label.c.IDPNewPasswordTitle"),
                                        body: modalBody, 
                                        showCloseButton: true,
                                        cssClass: "header-title", 
                                    })
                                }
                            });
    },
    
    handleEditRecord : function(component, event, helper) {
        var modalBody;
        $A.createComponents([
            ["c:REIDP_ProfileEditForm", 
             {
                 userId: component.get("v.userId")
             }],
        ],
            function(components, status) { 
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    component.find('overlayLib').showCustomModal({
                        header: $A.get("$Label.c.IDPEditRecord"),
                        body: modalBody, 
                        showCloseButton: true,
                        cssClass: "header-title"
                    })
                }
            });
    },
    
    checkUsername : function(component, event, helper) {
        var eventUsername = event.getParam("newUsername");
        component.set("v.userName", eventUsername);
    },
})