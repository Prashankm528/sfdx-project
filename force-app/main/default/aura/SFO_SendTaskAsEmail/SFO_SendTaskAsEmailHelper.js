({
    getTaskDetails : function(component, event, helper) {
       
        var action = component.get("c.getTaskDetails");
        action.setParams({"recordId": component.get("v.recordId")});

        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){

                component.set("v.Task", response.getReturnValue());
                
                    var action2 = component.get("c.getAssignmentOptions");        
                	action2.setParams({"recordId": component.get("v.recordId"), businessUnit: component.get("v.parentSpecificData[2]"), 
                                  salesOrg: component.get("v.parentSpecificData[1]")});
                	
                	action2.setCallback(this, function(response) {  
                    	var state2 = response.getState();
                    	if(state2 == "SUCCESS"){
	
                      	   component.set("v.options", response.getReturnValue());

                    	}
                    	else{
                        	 console.log('There was a problem and state2 is: ' + state2);

                   	 }    
                	}); 
                	$A.enqueueAction(action2);
                               
            } 
            else {
                console.log('There was a problem and state is: ' + state);
            }
        
        });
        $A.enqueueAction(action);
    },

    getParentSpecificDetails  : function(component, event, helper) {
        
        var action = component.get("c.getParentSpecificDetails");
        action.setParams({"recordId": component.get("v.recordId")});
        
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                
                component.set("v.parentSpecificData", response.getReturnValue());               
            }
            else {
                console.log('There was a problem and state is: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
       
    getTaskPriorityValues  : function(component, event, helper) {

        var action = component.get("c.getTaskPriorityValues");
        var inputsel = component.find("prioritydynamic");
        var opts=[];
        
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
                
            inputsel.set("v.options", opts);
        });

        $A.enqueueAction(action); 

    },
    
    getTaskType  : function(component, event, helper) {
        
        var action = component.get("c.getTaskType");
         action.setParams({"recordId": component.get("v.recordId")});
        
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                
                component.set("v.taskType", response.getReturnValue());               
            }
            else {
                console.log('There was a problem and state is: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
      
    
    saveTask  : function(component, event, helper) {
        
        // validate the Task before saving
        var taskHasErrors = false
        var errorMessages = [];
         
        if(component.get("v.taskType") != "SurveyTaker__c" && component.get("v.taskType") != "Opportunity" && component.get("v.taskType") != "Account"){
            taskHasErrors = true;
            errorMessages.push({value: "- The task must be associated to an Account, Opportunity or Survey" });
        } 	  
  
        if(component.get("v.Task.Subject") == ""  || component.get("v.Task.Subject") == null){
            taskHasErrors = true;
            errorMessages.push({value: "- The task must have a subject" });
        }

        if(component.get("v.Task.Task_Sent_as_Email__c") == true){
            taskHasErrors = true;
            errorMessages.push({value: "- The task has already been sent as email. Check status or send a new task" });
        }      

        if(component.find("sendTo").get("v.value") == "--None--"){
            taskHasErrors = true;
            errorMessages.push({value : "- Select a valid Send To option from the picklist" });
        } 


        // if validation failed, show error messages on component otherwise save the record 
        if(taskHasErrors == false){

            // save the Task and include the dynamic picklist value from sendTo picklist
            var action = component.get("c.saveTask");
            action.setParams({sendToName: component.find("sendTo").get("v.value"),
                            taskToSend: component.get("v.Task")});

            // set callback
            action.setCallback(this, function(a) {
                var response = a.getReturnValue();
                var state = action.getState();
                if(component.isValid() && state == "SUCCESS"){
                    
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "The Task has been sent as email",
                        "type": "success"
                    });

                    toastEvent.fire();

                }else if (state == "ERROR") {
                    console.log('There was a problem and the state is: '+ action.getState());
                }
            });

            $A.enqueueAction(action); 

        }
        // else - a validation check has occured, show errors on component 
        else{
            component.set("v.validationMessages", errorMessages);
            component.set("v.showMessages", true);
        }     
    }
})