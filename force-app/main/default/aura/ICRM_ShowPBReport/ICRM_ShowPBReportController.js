({
    // get the data for iframe
    handleApplicationEvent : function(component, event, helper) {
        component.set("v.PBReportName", event.getParam("PBName"));
        var action = component.get('c.getReport');
        action.setParams({
            reportName: event.getParam("PBName")
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var param = response.getReturnValue();
                if (param) {
                    var embedUrl = param.BPG_Embed_URL__c;
                    if (embedUrl && param.BPG_Page_Name__c) {
                        embedUrl += '&pageName=' + param.BPG_Page_Name__c;
                    }
                    component.set('v.embedURL',	embedUrl);
                }
            }
            
            else {
                $A.get("e.force:showToast")
                .setParams({
                    'title' : 'Message',
                    'message' : 'Something went wrong contact your System Admin',
                    'type' : 'Error'
                })
                .fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})