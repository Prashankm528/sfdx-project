({
    
    init : function (component,event,helper) {
        helper.createComp(component);
    },
    handleStatusChange : function (component, event) {
          
       
       	             var stopTimer = component.get('c.getCaseId');
                    var userId=$A.get("$SObjectType.CurrentUser.Id");
                    stopTimer.setParams({UserId:userId});
                    stopTimer.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state == 'SUCCESS') {
                            console.log('stopTimer: SUCCESS');
                        }
                        else if (state == 'INCOMPLETE') {
                            console.log('stopTimer: INCOMPLETE');
                        }
                            else if (state == 'ERROR') {
                                console.log('stopTimer: ERROR');
                            }
                    });
                    $A.enqueueAction(stopTimer);
                    console.log('StopTimerByCase: End');		
                	$A.enqueueAction(component.get('c.doRefresh'));
            
        
        //}
    },
    doRefresh : function(component,event,helper){
        console.log('inside refresh');
        
        
        if(component.find("findableAuraId")!=null || component.find("findableAuraId")!='undefined'){
            console.log('comp'+component.find("findableAuraId"));
            component.find("findableAuraId").destroy();
            console.log('comp destroyed');
            helper.createComp(component);
        }
    }
})