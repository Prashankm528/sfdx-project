({
    doInit : function(component, event, helper) {
        helper.init(component, event);
    },
    
    handledisableButton : function(component, event, helper) {
        var eventParam = event.getParam("status");
        if(eventParam=='DUP_Cancelled'){
            component.set("v.status",eventParam);              
            $A.get('e.force:refreshView').fire();
        }
        
    },
    
    showModal : function(component, event, helper) {
        var buttonName = event.getSource().get("v.name");
        if(buttonName=='reverse')
            helper.showModal(component, event, true);
        if(buttonName=='cancel'){
            var toShow = component.get("v.openPopup")                
            if(toShow){
                component.set("v.openPopup",false)
            }
            else{
                component.set("v.openPopup",true)
            }
        }
        else
            helper.showModal(component, event, false);
    },
    
    showEmailPreview : function(component, event, helper){
        var subAction = component.get("c.getEmailHTMLBody");
        subAction.setCallback(this, function(subResponse) {
            //var state = subResponse.getState();
            var email = subResponse.getReturnValue();
            component.set("v.emailBody",email);
        });
        $A.enqueueAction(subAction);
    },
    
    updateStage : function(component, event, helper) {
        var toShow = component.get("v.openPopup")
        
        if(toShow){
            component.set("v.openPopup",false)
        }
        else{
            component.set("v.openPopup",true)
        }
        helper.updateStage(component,event,false);
    },
    cancelRequest : function(component, event, helper) {
        helper.cancelRequest(component,event);
    },
    
})