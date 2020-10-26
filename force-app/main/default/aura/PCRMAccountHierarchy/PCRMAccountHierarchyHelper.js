({ 
    
    getParentAccountHelper : function (cmp, event, helper)
    {
        cmp.set("v.showSpinner", true); 
        
        var action = cmp.get("c.getParentAccount");
        action.setParams({ 
            Param_OpportunityId : cmp.get("v.OpportunityId")
        });
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response)
                           {
                               var state = response.getState();
                               if (state === "SUCCESS")
                               {
                                   // cmp.set("v.showSpinner", false); 
                                   cmp.set("v.parentAccountId",response.getReturnValue());
                                   
                                   //sonar q issue
                                   //var varParentAccountId =  cmp.get("v.parentAccountId");
                               }
                               else if (state === "INCOMPLETE") 
                               {
                                   // cmp.set("v.showSpinner", false); 
                                   // do something
                               }
                                   else if (state === "ERROR")
                                   {
                                       // cmp.set("v.showSpinner", false); 
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
    
    fireSelectedAccountsEvent : function (cmp,event,helper,updatedSelectedRowsInfo,notSelectedRowsInfo,treeGridSide) 
    {
        //var tree = cmp.find('treegrid_async');
        var cmpEvent = cmp.getEvent("SelectedAccountsEvent");
        
        cmpEvent.setParams({"SelectedAccountList" : updatedSelectedRowsInfo,
                            "ParentAccountId" : cmp.get("v.parentAccountId"),
                            "NotSelectedAccountList" : notSelectedRowsInfo,
                            "treeGrid_Side"  : treeGridSide
                           });
        
        cmpEvent.fire();
    },
    
    handleRowSelectionHelper : function (cmp,event,helper) 
    {
        var index ; 
        var varisRightTreeGreed = cmp.get("v.isRightTreeGreed");
        
        var existingAccounts ;
        if(varisRightTreeGreed == true) //right
        {
            existingAccounts = cmp.get("v.Unformated_ExistingAccountsOnRight"); 
        }
        if (varisRightTreeGreed == false) //left
        {
            existingAccounts = cmp.get("v.Unformated_ExistingAccountsOnLeft"); 
        }
        
        var existingAccountsId = [];  
        
        if(existingAccounts != null) 
        {
            for(var n = 0; n < existingAccounts.length; n++)
            {
                existingAccountsId.push(existingAccounts[n].Id);
            }
        }
        
        //detail info for updated selected rows 
        var updatedSelectedRowsInfo = [];    
        
        //detail info for not selected rows   
        var notSelectedRowsInfo = [];  
        
        //fetching info from predefined map   
        var MapOfRowKeyFieldRowDetail  =  cmp.get("v.MapOfRowKeyField_RowDetail");
        
        //get map of child and its parent row  
        var varChildParentKeyfield  =cmp.get("v.MapOfChildParentKeyfield");     
        
        var newSelectedRowIds = event.getParam('selectedRows');
        var existingSelectedRowIds = cmp.get("v.selectedIds");
        
        //alert('existingSelectedRowIds: '+existingSelectedRowIds);  
        
        var updatedSelectedRows = [];     
        var newAddedRows =[];  
        
        //as on any row selection we get all the selected row,compairing existing selected rows with new selected rows to get current row
        //fetching if any new row added or deleted// and adding mutual rows in updatedSelectedRows
        for(var n = 0; n < newSelectedRowIds.length; n++)
        {
            if(existingSelectedRowIds.includes(newSelectedRowIds[n].Id))  
            {
                var varindex = existingSelectedRowIds.indexOf(newSelectedRowIds[n].Id);
                
                existingSelectedRowIds.splice(varindex,1);
                
                //adding existing row
                updatedSelectedRows.push(newSelectedRowIds[n].Id);
                
                //adding existing row info
                updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[newSelectedRowIds[n].Id]);
            }
            else
            {
                newAddedRows.push(newSelectedRowIds[n].Id);
            }
            
        }
        
        var rowKeyField ;
        var varParentRowKeyField = '';   
        
        var uncheckedRow = existingSelectedRowIds;  
        
        //if the new row is added
        for (var i = 0; i < newAddedRows.length; i++)
        {
            //adding current row in selected rows list
            /*if(updatedSelectedRows.includes(newAddedRows[i]))
            {
                
            }
            else*/
            {
                if(!updatedSelectedRows.includes(newAddedRows[i]))
                {//adding Ids
                updatedSelectedRows.push(newAddedRows[i]);
                
                var SelectedRowsChildren =  MapOfRowKeyFieldRowDetail[newAddedRows[i]]._children;
                
                for(var k = 0; k < SelectedRowsChildren.length; k++)
                {
                    //adding childern id
                    if(!updatedSelectedRows.includes(SelectedRowsChildren[k].Id))
                    {
                         updatedSelectedRows.push(SelectedRowsChildren[k].Id);
                    }
                    /*else
                    {
                        updatedSelectedRows.push(SelectedRowsChildren[k].Id);
                    }*/
                    
                    //adding childern info
                    if(!updatedSelectedRowsInfo.includes(MapOfRowKeyFieldRowDetail[SelectedRowsChildren[k].Id]))
                    {
                  		 updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[SelectedRowsChildren[k].Id]);
                    }
                    /*else
                    {
                        updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[SelectedRowsChildren[k].Id]);
                    }*/
                    
                }
                }
            }
            
            //adding detail info for updated selected rows 
            if(!updatedSelectedRowsInfo.includes(MapOfRowKeyFieldRowDetail[newAddedRows[i]]))
            {
                 //adding info
                updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[newAddedRows[i]]);
                //('added detail');
            }
            /*else
            {
                //adding info
                updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[newAddedRows[i]]);
                //('added detail');
            }*/
            
            rowKeyField = newAddedRows[i];
            varParentRowKeyField = '';   
            
            //this loop will work till row has parent row
            //checking row has parent row or not, if yes then add them too into list 
            //this will add current rows' parent row and parent rows's parent if it exist
            while (varParentRowKeyField != undefined) 
            {
                //checking child id present in varChildParentKeyfield => map of row id and its parent row id
                if(varChildParentKeyfield[rowKeyField] != undefined )
                {
                    if(varChildParentKeyfield[rowKeyField].parentRowKeyField != undefined)
                    {
                        varParentRowKeyField = varChildParentKeyfield[rowKeyField].parentRowKeyField;
                        
                        if(!updatedSelectedRows.includes(varParentRowKeyField))
                        {
                           updatedSelectedRows.push(varParentRowKeyField);
                        }
                        else
                        {
                           // updatedSelectedRows.push(varParentRowKeyField);
                        }
                        
                        
                        
                        if(!updatedSelectedRowsInfo.includes(MapOfRowKeyFieldRowDetail[varParentRowKeyField])) 
                        {
                             if( MapOfRowKeyFieldRowDetail[varParentRowKeyField] != undefined)  
                            {
                                updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[varParentRowKeyField]);
                            }
                        }
                        /*else  
                        {
                            if( MapOfRowKeyFieldRowDetail[varParentRowKeyField] != undefined)  
                            {
                                updatedSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[varParentRowKeyField]);
                            }
                        }*/
                        
                        rowKeyField = varParentRowKeyField;
                    }
                    else 
                    {
                        varParentRowKeyField = undefined;
                    }
                }
                else
                {
                    varParentRowKeyField = undefined;  
                }
            }
            
        }       
        
        //when you unchecked any row, and that row's parent row not having any checked rows except current one..parent row should be unchecked   
        // var mapOfuncheckedRow_parentsChildern = {};  
        var parentsChildernIds   = [];
        
        //if the one of the existing row is deleted
        for (var i = 0; i < uncheckedRow.length; i++)
        {
            if(MapOfRowKeyFieldRowDetail[uncheckedRow[i]] != undefined)
            {
                //getting childern of row
                var Children =  MapOfRowKeyFieldRowDetail[uncheckedRow[i]]._children;
                
                if(Children.length > 0)
                {
                    for(var m = 0; m < Children.length; m++)
                    {
                        //remove that child
                        if(updatedSelectedRows.includes(Children[m].Id))  
                        {
                            index = updatedSelectedRows.indexOf(Children[m].Id);
                            updatedSelectedRows.splice(index,1);
                        }
                        
                        //removing childern detail info  
                        if(updatedSelectedRowsInfo.includes(MapOfRowKeyFieldRowDetail[Children[m].Id]))
                        {
                            index = updatedSelectedRowsInfo.indexOf(MapOfRowKeyFieldRowDetail[Children[m].Id]);
                            updatedSelectedRowsInfo.splice(index,1);
                        }
                    }
                }
                
                if(MapOfRowKeyFieldRowDetail[uncheckedRow[i]] != undefined)
                {
                    // get unchecked rows' parent id
                    var parentId = MapOfRowKeyFieldRowDetail[uncheckedRow[i]].ParentId;
                    
                    //get that parent's childern
                    if(  MapOfRowKeyFieldRowDetail[parentId] != undefined)
                    {
                        var parentsChildern =  MapOfRowKeyFieldRowDetail[parentId]._children;
                        if(parentsChildern.length > 1)
                        {
                            for(var m = 0; m < parentsChildern.length; m++)
                            {
                                if(parentsChildern[m].Id != uncheckedRow[i])//excluding current uncheck row
                                    parentsChildernIds.push(parentsChildern[m].Id);
                            }
                        }
                        else if(parentsChildern.length == 1)//if it has only one child
                        {
                            parentsChildernIds.push(uncheckedRow[i]);
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        
        cmp.set("v.selectedIds",updatedSelectedRows);
        
        var childenNotSelected =[];    
        //when you unchecked any row, and that row's parent row not having any checked rows except current one..parent row should be unchecked   
        for(var m = 0; m < parentsChildernIds.length; m++)
        {
            if(!updatedSelectedRows.includes(parentsChildernIds[m]))
            {
                childenNotSelected.push(parentsChildernIds[m]);
            }
            
        }
        
        // if non of remaining childern are part of selected List then its parent should also get unselected   
        if(parentsChildernIds.length == childenNotSelected.length )
        {
            if(varChildParentKeyfield[childenNotSelected[0]] != undefined)
            {
                var parentId = varChildParentKeyfield[childenNotSelected[0]].parentRowKeyField;
                index = updatedSelectedRows.indexOf(parentId);
                updatedSelectedRows.splice(index,1);
            }
        }
        
        cmp.set("v.selectedIds",updatedSelectedRows);  
        
        //not selected rows info  
        var selectedIdsOnLeft =[];//placeholder to avoid duplicate accounts addition  
        
        if(existingAccountsId.length > 0)
        {
            for(var n = 0; n < existingAccountsId.length; n++)
            {
                //fetching only notselected rows
                if(!updatedSelectedRows.includes(existingAccountsId[n]))
                {
                    if(!selectedIdsOnLeft.includes(existingAccountsId[n]))
                    {
                        notSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[existingAccountsId[n]]);
                    }
                    
                    selectedIdsOnLeft.push(existingAccountsId[n]);
                    
                    //checking its parent is selected or not
                    if(MapOfRowKeyFieldRowDetail[existingAccountsId[n]] != undefined)
                    { 
                        if(updatedSelectedRows.includes(MapOfRowKeyFieldRowDetail[existingAccountsId[n]].ParentId))
                        {
                            var parntId = MapOfRowKeyFieldRowDetail[existingAccountsId[n]].ParentId;
                            
                            if(MapOfRowKeyFieldRowDetail[parntId] != undefined)
                            {
                                if(!selectedIdsOnLeft.includes(parntId)) 
                                {
                                    notSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[parntId]);
                                }
                                
                                selectedIdsOnLeft.push(parntId); 
                            }
                            
                        }
                        else
                        {
                            if(!selectedIdsOnLeft.includes(existingAccountsId[n]))
                            {
                                notSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[existingAccountsId[n]]);
                            }
                            
                            selectedIdsOnLeft.push(existingAccountsId[n]);
                            
                            //checking its parent is selected or not
                            if(updatedSelectedRows.includes(MapOfRowKeyFieldRowDetail[existingAccountsId[n]].ParentId))
                            {
                                var parntId = MapOfRowKeyFieldRowDetail[existingAccountsId[n]].ParentId;
                                
                                if(MapOfRowKeyFieldRowDetail[parntId] != undefined)
                                {
                                    if(!selectedIdsOnLeft.includes(parntId)) 
                                    {
                                        notSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[parntId]);
                                    }
                                    
                                    selectedIdsOnLeft.push(parntId); 
                                }
                                
                            }
                        }
                    }
                    
                }
            } 
        }
        else
        {
            for(var key in MapOfRowKeyFieldRowDetail)
            {
                //fetching only notselected rows
                if(!updatedSelectedRows.includes(key))
                {
                    if(!selectedIdsOnLeft.includes(key))
                    {
                        notSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[key]);
                    }
                    
                    selectedIdsOnLeft.push(key);
                    
                    //checking its parent is selected or not
                    if(updatedSelectedRows.includes(MapOfRowKeyFieldRowDetail[key].ParentId))
                    {
                        var parntId = MapOfRowKeyFieldRowDetail[key].ParentId;
                        
                        if(MapOfRowKeyFieldRowDetail[parntId] != undefined)
                        {
                            if(!selectedIdsOnLeft.includes(parntId)) 
                            {
                                notSelectedRowsInfo.push(MapOfRowKeyFieldRowDetail[parntId]);
                            }
                            
                            selectedIdsOnLeft.push(parntId); 
                        }
                        
                    }
                    
                }
            }
        }
        
        if(varisRightTreeGreed == true)  
        {
            var treeGridSide = 'Right';
        }
        if(varisRightTreeGreed == false)  
        {
            var treeGridSide = 'Left';
        }  
        
        // calling helper method to fire event and pass list of Account to parent component 
        helper.fireSelectedAccountsEvent(cmp,event,helper,updatedSelectedRowsInfo,notSelectedRowsInfo,treeGridSide);
    }
    
})