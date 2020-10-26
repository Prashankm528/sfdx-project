({
	//this will format list of accounts into Hierarchy 
	//this method will get called when List of accounts are passed from apex side also and when passed from Client side 
    createHierarchy : function(cmp,unformattedAccounts,varParentAcc) 
    {
        //Account => Type picklist value,Lable map
        var varMapOfPicklistValuewithLable = cmp.get("v.MapOfPicklistValuewithLable");
        
        if(cmp.get("v.MapOfChildParentKeyfield") != null) //if opportunity is already associated with Accounts...updating =>MapOfChildParentKeyfield 
        {
        	var varMapOfChildParentKeyfield = cmp.get("v.MapOfChildParentKeyfield" );    
        }
        else//if user is associating account with opportunity for first time...creating for the fisrt time=> MapOfChildParentKeyfield...
        {
             var varMapOfChildParentKeyfield = {};
        }
        
        if(cmp.get("v.MapOfRowKeyField_RowDetail") != null)//if opportunity is already associated with Accounts
        {
        	var varMapOfRowKeyField_RowDetail = cmp.get("v.MapOfRowKeyField_RowDetail");  
        }
        else//if user is associating account with opportunity for first time
        {
            var varMapOfRowKeyField_RowDetail = {};
        }
        
        var expandedRows = [];
        var apexResponse = unformattedAccounts;

        var roles = {};
        
        //sonar q issue
        //var results = apexResponse;
        
        roles[undefined] = { Name: "Root", _children: [] };
        apexResponse.forEach(function(v) 
                             {
                                 //when this method called from apex side Type having api name and when called from client side Type will have lable value
                                 //if(v.Type == 'Sold-To Party' || v.Type == 'Ship-To Party'  )
                                 if(v.Type == 'ZMSP' || v.Type == 'ZMSH' || v.Type == varMapOfPicklistValuewithLable['ZMSP'] || v.Type ==  varMapOfPicklistValuewithLable['ZMSH'])//only sold to party and ship to party
                                 {
                                    //alert('client: '+varMapOfPicklistValuewithLable[v.Type])
                                     if(varMapOfPicklistValuewithLable[v.Type] == undefined)//from client
                                     {
                                         var typeValue = v.Type;
                                     }
                                     else//from server
                                     {
                                         var typeValue = varMapOfPicklistValuewithLable[v.Type] ;
                                     }    
                                         
                                 expandedRows.push(v.Id);
                                 roles[v.Id] = 
                                     { 
                                         Name : v.Name ,
                                         Id : v.Id,
                                         varKeyField: v.Id, 
                                         //Type: v.Type,
                                         Type: typeValue,
                                         AccountURL:'/'+v.Id,
                                         ParentId : v.ParentId,
                                         PCRM_Inco_Terms__c : v.PCRM_Inco_Terms__c,
                                         PCRM_Inco_Terms_2__c : v.PCRM_Inco_Terms_2__c,
                                         _children: []
                                     };
                                     
                                 varMapOfRowKeyField_RowDetail[v.Id] = roles[v.Id];
                                 }    
                             });
        
        apexResponse.forEach(function(v) 
                             {
                               //if(v.Type == 'Sold-To Party' || v.Type == 'Ship-To Party'  )
                               if(v.Type == 'ZMSP' || v.Type == 'ZMSH' || v.Type == varMapOfPicklistValuewithLable['ZMSP'] || v.Type ==  varMapOfPicklistValuewithLable['ZMSH'])//only sold to party and ship to party
                               {
                                 varMapOfChildParentKeyfield[v.Id] = {parentRowKeyField :  v.ParentId  };
                                   
                                  //as considering only account on which opportunity is created and its children accounts and not its parent account
                                  //so if opportunity is created on Sold to account,its parent customer group account will not be available here
                                 if(roles[v.ParentId] == undefined )
                                 {
                                     //adding parent account(on which opportunity is created) as child of undefined to include it as topmost in hierarchy
                                     roles[undefined]._children.push(roles[v.Id]);
                                 }
                                 else
                                 {
                                      roles[v.ParentId]._children.push(roles[v.Id]); 
                                 }
                               }
                                
                             });   
        
        /* if(cmp.get("v.isRightTreeGreed") == false) //left
            {
                cmp.set("v.formatedAccountsOnLeft", roles[undefined]._children);
            }*/
        
        cmp.set('v.showSpinner',false);
        
        cmp.set("v.MapOfChildParentKeyfield",varMapOfChildParentKeyfield );    
        cmp.set("v.MapOfRowKeyField_RowDetail",varMapOfRowKeyField_RowDetail );   
        
        
        //cmp.set('v.gridExpandedRowsOnRight', expandedRows);
        //cmp.set("v.formatedAccountsOnRight", roles[undefined]._children);
        var responseFromHelper = [];
        responseFromHelper.push(roles[undefined]._children);
        responseFromHelper.push(expandedRows);
        //responseFromHelper.push(selectedIds);
        return responseFromHelper;
        
    },
    //get parent account on which opportunity is initially created
    getParentAccountIdHelper : function(cmp,helper,event) 
    {
       var action = cmp.get("c.getParentAccount");
       action.setParams({ 
                           Param_OpportunityId : cmp.get('v.recordId'), 
                        });
        
       // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response)
        {
           var state = response.getState();
           if (state === "SUCCESS")
           {
               cmp.set("v.topAccountId",response.getReturnValue());
               helper.getOpportunityRelatedAccountsHelper(cmp,helper,event);
           }
            else if (state === "INCOMPLETE") 
            {
                cmp.set("v.showSpinner", false); 
                // do something
            }
            else if (state === "ERROR")
            {
                 cmp.set("v.showSpinner", false); 
                var errors = response.getError();
                if (errors)
                {
                    if (errors[0] && errors[0].message)
                    {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else 
                {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);  
    },
    //get all the accounts link to opportunity
    getOpportunityRelatedAccountsHelper : function(cmp,helper,event) 
    {
        cmp.set('v.showSpinner',true);
        
        var varParentAcc =  cmp.get("v.topAccountId");
        var action = cmp.get("c.getOpportunityRelatedAccounts");
        action.setParams({ 
            paramOpportunityId : cmp.get('v.recordId'), 
            paramParentAccId : varParentAcc
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   cmp.set('v.showSpinner',false);

                                   var varAccountsRelatedToOpportunity = response.getReturnValue()['OpportunityRelatedAccounts'];
                                   var varAccountsNotRelatedToOpportunity = response.getReturnValue()['OpportunityNotRelatedAccounts'];

                                   cmp.set("v.UnformatedExistingAccountsOnLeft", varAccountsNotRelatedToOpportunity);
                                   cmp.set("v.UnformatedExistingAccountsOnRight", varAccountsRelatedToOpportunity);
 
                                   var resp = [];
                                   
                                   if(varAccountsRelatedToOpportunity.length > 0)
                                   {
                                       cmp.set('v.showSpinner',true);
                                       //call helper method to format accounts in tree grid
                                       resp = helper.createHierarchy(cmp,varAccountsRelatedToOpportunity,varParentAcc);
                                       
                                       cmp.set("v.formatedAccountsOnRight", resp[0]);
                                       cmp.set('v.gridExpandedRowsOnRight', resp[1]);
                                   }
                                     if(varAccountsNotRelatedToOpportunity.length > 0)
                                     {
                                       cmp.set('v.showSpinner',true);  
                                       resp = helper.createHierarchy(cmp,varAccountsNotRelatedToOpportunity,varParentAcc);
                                       
                                         
                                         
                                       cmp.set("v.formatedAccountsOnLeft", resp[0]);
                                       cmp.set('v.gridExpandedRowsOnLeft', resp[1]);
                                       
                                     }
                                   
                                    if(varAccountsRelatedToOpportunity.length == 0)
                                     {
                                       //cmp.set('v.showSpinner',true);  
                                       //resp = helper.createHierarchy(cmp,varAccountsNotRelatedToOpportunity,varParentAcc);
                                       
                                       cmp.set("v.formatedAccountsOnRight", null);
                                       cmp.set('v.gridExpandedRowsOnRight', null);
                                       
                                     }
                                   
                                   
                                   
                               }
                               else if (state === "INCOMPLETE") 
                               {
                                   cmp.set("v.showSpinner", false); 
                                   // do something
                               }
                                   else if (state === "ERROR")
                                   {
                                       cmp.set("v.showSpinner", false); 
                                       var errors = response.getError();
                                       if (errors)
                                       {
                                           if (errors[0] && errors[0].message)
                                           {
                                               console.log("Error message: " + 
                                                           errors[0].message);
                                           }
                                       } else 
                                       {
                                           console.log("Unknown error");
                                       }
                                   }
                           });
        
        $A.enqueueAction(action);
     },
    
    findPicklistOptionsHelper: function (cmp,helper,event)
    {
        //getting Account's Type picklist fields value and lable map
        var action = cmp.get("c.findPicklistOptions");
        action.setParams({ 
            objAPIName : 'Account', 
            fieldAPIname : 'Type'
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   cmp.set("v.MapOfPicklistValuewithLable",response.getReturnValue());
                                   
                                   //cmp.set('v.showSpinner',false);
                                    helper.getParentAccountIdHelper(cmp,helper,event);  
                               }
                               else if (state === "INCOMPLETE") 
                               {
                                   cmp.set("v.showSpinner", false); 
                                   // do something
                               }
                                   else if (state === "ERROR")
                                   {
                                       cmp.set("v.showSpinner", false); 
                                       var errors = response.getError();
                                       if (errors)
                                       {
                                           if (errors[0] && errors[0].message)
                                           {
                                               console.log("Error message: " + 
                                                           errors[0].message);
                                           }
                                       } else 
                                       {
                                           console.log("Unknown error");
                                       }
                                   }
                           });
        
        $A.enqueueAction(action);
    }
})