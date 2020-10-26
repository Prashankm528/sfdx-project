({
   doInit: function (cmp, event, helper)
    {     
      cmp.set('v.showSpinner',true);
      helper.findPicklistOptionsHelper(cmp,helper,event);   
    },
    //List of accounts receved from left side tree grid/event
    getAccountsFromEvent: function(cmp, event, helper)
    {
        //get value from event
        var varAccountsFromEvent = event.getParam("SelectedAccountList");
        var varParentAccIdFromEvent = event.getParam("ParentAccountId");
        var varNotSelectedAccountList = event.getParam("NotSelectedAccountList");
        var vartreeGrid_Side = event.getParam("treeGrid_Side");

        cmp.set("v.ParentAccIdFromEvent",varParentAccIdFromEvent);

        //when the accounts are from right side tree grid to parent component via event
        if(vartreeGrid_Side == "Right")
        {
            //set accounts from event
            cmp.set("v.RightGridAccountsFromEvent",varAccountsFromEvent);
            cmp.set("v.RightGridNotSelectedAccountFromEvent",varNotSelectedAccountList);
        }
       
        //when the accounts are from left side tree grid to parent component via event
        if(vartreeGrid_Side == "Left")
        {
             //set accounts from event
            cmp.set("v.LeftGridAccountsFromEvent",varAccountsFromEvent);
            cmp.set("v.LeftGridNotSelectedAccountFromEvent",varNotSelectedAccountList);
        }
        
        
    },
    //before passing to right tree grid it need to format in hierarchy structure
    onRightArrowClick : function(cmp, event, helper)
    {
        if(cmp.get("v.LeftGridAccountsFromEvent") != null)
        {
        if(cmp.get("v.LeftGridAccountsFromEvent").length > 0)
        {
            //fetching selected accounts from left tree grid which received via event which need to be passed to right tree grid
            var UnformatedAccountsOnRight = cmp.get("v.LeftGridAccountsFromEvent");
        
            //checking if there are any existing accounts or not
            //updating accounts receved from event with existing accounts available on right tree grid
            if(cmp.get("v.UnformatedExistingAccountsOnRight") !=  null)
            {
                var ListOfExistngIds = [];
                
                var varUnformatedExistingAccountsOnRight = cmp.get("v.UnformatedExistingAccountsOnRight");
                
                 for(var i = 0; i < varUnformatedExistingAccountsOnRight.length; i++)
                 {
                     ListOfExistngIds.push(varUnformatedExistingAccountsOnRight[i].Id);
                 }
                
                for(var i = 0; i < UnformatedAccountsOnRight.length; i++)
                {
                    //exsiting list from right get added with new accounts dragged from left
                    if(!ListOfExistngIds.includes(UnformatedAccountsOnRight[i].Id))
                    {
                        varUnformatedExistingAccountsOnRight.push(UnformatedAccountsOnRight[i]);
                    }
                   /*alert('event first element: '+UnformatedAccountsOnRight[i]);
                    for(var j = 0; j < varUnformatedExistingAccountsOnRight.length; j++)
                        {
                            alert('exi elemt: '+ varUnformatedExistingAccountsOnRight[j]);
                            if(UnformatedAccountsOnRight[i].Id == varUnformatedExistingAccountsOnRight[j].Id)
                            {
                                alert('same');
                            }
                            else
                            {
                                varUnformatedExistingAccountsOnRight.push(UnformatedAccountsOnRight[i]);
                            }
                        }*/
                }
            }
            else
            {
                //if there are no existing accounts selected at right side consider all accounts receved from event
                varUnformatedExistingAccountsOnRight = UnformatedAccountsOnRight;
            }
        
            cmp.set("v.UnformatedExistingAccountsOnRight",varUnformatedExistingAccountsOnRight); 
            
            var varParentAcc = cmp.get("v.ParentAccIdFromEvent");
            var UnformattedAccountsLeft = cmp.get("v.LeftGridNotSelectedAccountFromEvent");//not selected accounts from left tree grid supposed to be remain at left side
           
            var unformattedAccounts = [];
            unformattedAccounts = varUnformatedExistingAccountsOnRight; //unformattedAccounts => parameter on helper method
    
            var response = [];
            //calling helper method to format (not in HierarchyFormat) List of accounts recevied from event
            response =  helper.createHierarchy(cmp,unformattedAccounts,varParentAcc);
            
            cmp.set("v.formatedAccountsOnRight", response[0]);
            cmp.set('v.gridExpandedRowsOnRight', response[1]);
            
            cmp.set("v.UnformatedExistingAccountsOnLeft", UnformattedAccountsLeft);
            unformattedAccounts = [];
            unformattedAccounts = UnformattedAccountsLeft;
            response = [];
            response = helper.createHierarchy(cmp,unformattedAccounts,varParentAcc);
            
            cmp.set("v.formatedAccountsOnLeft", response[0]);
            cmp.set("v.gridExpandedRowsOnLeft",response[1]);
            
            
            cmp.set("v.LeftGridAccountsFromEvent",null)
            cmp.set("v.LeftGridNotSelectedAccountFromEvent",null)
            
        }
        }
    },
    onLeftArrowClick : function(cmp, event, helper)
    {
       if(cmp.get("v.RightGridAccountsFromEvent") != null) 
       {if(cmp.get("v.RightGridAccountsFromEvent").length > 0)
        {
            var UnformatedAccountsOnLeft = cmp.get("v.RightGridAccountsFromEvent");//which are suppose to copy to left grid
    
            //checking if there are any existing accounts or not
            //updating accounts receved from event with existing accounts available on left tree grid
            if(cmp.get("v.UnformatedExistingAccountsOnLeft") !=  null)
            {
                var ListOfExistngIds = [];
                
                var varUnformatedExistingAccountsOnLeft = cmp.get("v.UnformatedExistingAccountsOnLeft");
                
                 for(var i = 0; i < varUnformatedExistingAccountsOnLeft.length; i++)
                 {
                     ListOfExistngIds.push(varUnformatedExistingAccountsOnLeft[i].Id);
                 }
                
                for(var i = 0; i < UnformatedAccountsOnLeft.length; i++)
                {
                    if(!ListOfExistngIds.includes(UnformatedAccountsOnLeft[i].Id))
                    {
                        varUnformatedExistingAccountsOnLeft.push(UnformatedAccountsOnLeft[i]);
                    }
                  
                }
            }
            else
            {
                //if there are no existing accounts selected at right side consider all accounts receved from event
                varUnformatedExistingAccountsOnLeft = UnformatedAccountsOnLeft;
            }
        
            cmp.set("v.UnformatedExistingAccountsOnLeft",varUnformatedExistingAccountsOnLeft); 
            
            var varParentAcc = cmp.get("v.ParentAccIdFromEvent");
            var UnformattedAccountsRight = cmp.get("v.RightGridNotSelectedAccountFromEvent");
           
            var unformattedAccounts = [];
            unformattedAccounts = varUnformatedExistingAccountsOnLeft; //unformattedAccounts => parameter on helper method
    
            var response = [];
            //calling helper method to format (not in HierarchyFormat) List of accounts recevied from event
            response =  helper.createHierarchy(cmp,unformattedAccounts,varParentAcc);
            
            cmp.set("v.formatedAccountsOnLeft", response[0]);
            cmp.set('v.gridExpandedRowsOnLeft', response[1]);
        
            cmp.set("v.UnformatedExistingAccountsOnRight", UnformattedAccountsRight);
            
            unformattedAccounts = [];
            unformattedAccounts = UnformattedAccountsRight;
            response = [];
            response = helper.createHierarchy(cmp,unformattedAccounts,varParentAcc);
            
            cmp.set("v.formatedAccountsOnRight", response[0]);
            cmp.set("v.gridExpandedRowsOnRight",response[1]);
            
            cmp.set("v.RightGridAccountsFromEvent",null)
            cmp.set("v.RightGridNotSelectedAccountFromEvent",null);
            
            
            
        }}
        
    },
    OnclickSave : function (cmp,event,helper) 
    {
       //sonar q issu 
      //var varUnformatedAccountsOnRight = cmp.get("v.AccountsFromEvent") ;
      
      //show spinner on saving
      cmp.set("v.showSpinner", true); 
        
       //sonar 
      //var lstOfaccounts = cmp.get("v.formatedAccountsOnRight"); //pending       
        
      var action = cmp.get("c.createDeleteOpportunityAccounts");
       action.setParams({ 
                           paramOpportunityId : cmp.get('v.recordId'), 
                           paramAccountsTobAssociated : cmp.get("v.UnformatedExistingAccountsOnRight")
                        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response)
        {
           var state = response.getState();
          // alert('state: '+state);
            
           if (state === "SUCCESS")
           {
               cmp.set("v.showSpinner", false); 
               
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "All Customers has been associated successfully.",
                    "type" : "success"
                });
                toastEvent.fire();
                cmp.set('v.showSpinner',true);
    			helper.getParentAccountIdHelper(cmp,helper,event); 
               $A.get('e.force:refreshView').fire();
           }
            else if (state === "INCOMPLETE") 
            {
                cmp.set("v.showSpinner", false); 
                var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "INCOMPLETE Please try again",
                            "type" : "error"
                		});
                		toastEvent.fire();
            }
            else if (state === "ERROR")
            {
                cmp.set("v.showSpinner", false); 
                var errors = response.getError();
                if (errors)
                {
                    if (errors[0] && errors[0].message)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": errors[0].message,
                            "type" : "error"
                		});
                		toastEvent.fire();
                        
                    }
                } else 
                {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    OnclickCancel : function (cmp,event,helper) 
    {
        cmp.set('v.showSpinner',true);
    	helper.getParentAccountIdHelper(cmp,helper,event);  
    }
    
})