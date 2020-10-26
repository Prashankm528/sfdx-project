({
    showRowDetails : function(component,row) {
        var modalBody;
        var modalFooter;
        var rowAppId = row.Id;
        var labelRequestAccess = $A.get("$Label.c.REIDP_RequestAccessLabel");
        $A.createComponents([['c:REIDP_ApplicationOverlayBody'],
                             ['c:REIDP_ApplicationFooterCancelSave', {'applicationId':rowAppId}]],
                            function(components, status){
                                if (status === "SUCCESS") {
                                    modalBody = components[0];
                                    modalFooter = components[1];
                                    component.find('overlayLib').showCustomModal({
                                        header: labelRequestAccess,
                                        body: modalBody, 
                                        footer: modalFooter,
                                        showCloseButton: true,
                                        closeCallback: function() {
                                            modalBody.destroy();
                                            modalFooter.destroy();
                                        }
                                    });
                                }
                            }
                           );
    },
    
    getAppList: function(component) {
        var raAction = component.get('c.getListOfRestrictedApps');
        // Set up the callback
        var self = this;
        raAction.setCallback(this, function(actionResult) {
            component.set('v.data', actionResult.getReturnValue());
        });
        $A.enqueueAction(raAction);
    }, 
})