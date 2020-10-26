({
    handleDelete: function(component, event, helper) {
        var accountId = component.get("v.recordId");
        console.log(accountId);
        if(accountId !=null && accountId !=undefined) {
            console.log(accountId);
            var delAction = component.get("c.DeleteAndAnonymizeCommunityUser");
            delAction.setParams({
                "accountId": accountId
            });
            delAction.setCallback(this, function(a) {
                var state = a.getState();
                var closeTab = false;
                var toastEvent = $A.get("e.force:showToast");
                if(component.isValid() && state == "SUCCESS") {
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "mode" : "sticky",
                        "message": "User was deleted & anonymized"
                    });
                    closeTab = true;
                } else if (state == "ERROR") {
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": a.getError()[0].message
                    });
                }
                toastEvent.fire();
                //Close quick action box
                $A.get("e.force:closeQuickAction").fire();
                //Close current console tab if user was deleted
                var workspaceAPI = component.find("workspace");
                if(closeTab && workspaceAPI != null && workspaceAPI != undefined) {
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    });
                }
            });
            $A.enqueueAction(delAction);
        }
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})