({
                 
    loadRecords : function(component, event, helper) {
        
        //var action = component.get('c.loadLOVRecords');
        var action = component.get('c.loadRecords');
        var recId = component.get("v.recordId");
        component.set("v.fileList",null);
        action.setParams({
            'docReqId': recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(component, event, helper );
            if(component.isValid() && state === 'SUCCESS'){ 
                var groupMap = response.getReturnValue();
                var arrayMapKeys = [];
                var itemList = [];
                var uiMap = [];
                var counterCertified = 0;
                for(var key in groupMap){
                    var obj = new Object();
                    obj.key = key;
                    obj.isExpanded = false;
                    uiMap.push(obj);
                    for(var i = 0; i < (groupMap[key]).length; i++){
                        groupMap[key][i].searchText = "";
                        groupMap[key][i].searchTextTemplate = "";
                        groupMap[key][i].changed = false;
                        if(groupMap[key][i].DUP_Document_Template__r){
                            if(groupMap[key][i].DUP_Document_Template__r.Name.length>45){
                                groupMap[key][i].DUP_Document_Template__r.Name = (groupMap[key][i].DUP_Document_Template__r.Name).substring(0,45)+"..."
                            }
                        }
                        if(groupMap[key][i].DUP_Certified_True_Copy__c){
                            counterCertified += 1;
                        }
                        if(groupMap[key][i].ContentDocumentLinks!=null && groupMap[key][i].ContentDocumentLinks!='')
                            this.addFileList(component, event, helper,groupMap[key][i].Id, groupMap[key][i].ContentDocumentLinks);
                    }           
                    arrayMapKeys.push({key: key, value: groupMap[key]});
                    itemList = itemList.concat(groupMap[key]);
                }
                component.set("v.titleMap", arrayMapKeys);
                component.set("v.uiMap", uiMap);
                component.set("v.itemList", itemList);
                component.set("v.counterCertified", counterCertified);
                component.set('v.loaded', !component.get('v.loaded'));
            }
            else {
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(action);
    }, 
    addFileList : function(component, event, helper, docStoreId, filesPerItem) {
        //console.log(docStoreId+'  --  ' +JSON.stringify(filesPerItem))
        var temp = [];
        var recordsToDisplay = [];
        if(filesPerItem!=null)
            for(var i = 0; i < filesPerItem.length; i++){
                var fileObj = new Object();
                fileObj.id = filesPerItem[i].Id;
                fileObj.fileId = filesPerItem[i].ContentDocument.Id;
                if((filesPerItem[i].ContentDocument.Title).length>35)
                    fileObj.title = (filesPerItem[i].ContentDocument.Title).substring(0,35)+"...";
                else
                    fileObj.title = filesPerItem[i].ContentDocument.Title;
                temp.push(fileObj);
            }
        var oldFiles = component.get("v.fileList");
        if(oldFiles==null || oldFiles==undefined){
            oldFiles=[];
        }
        var recordToPush = new Object();
        recordToPush.docStoreId = docStoreId;
        recordToPush.files = temp;
        oldFiles.push(recordToPush);
        component.set("v.fileList",oldFiles);
    }, 
    
    isArray: function (what) {
        return Object.prototype.toString.call(what) === '[object Array]';
    }, 
        
    doUpdate : function (component,event,helper){
        
        //var itemList = component.get("v.itemList");  
        var items = component.get("v.titleMap");
        var itemsToUpdate = [];
        var itemsUpdated = []
        for(var key in items){
            var temp = items[key].value;
            for(i = 0; i < temp.length; i++){
                if(temp[i].changed){
                    itemsToUpdate.push(temp[i]);
                    items[key].value[i].changed = false;
                }
            }
            itemsUpdated.push(items[key]);
        }
        component.set("v.titleMap",itemsUpdated);

        // the component sets cleared lookup values as blank arrays , update these to be empty strings
        var i;
        if(itemsToUpdate.length>0){
        for (i = 0; i < itemsToUpdate.length; i++) {
            if (this.isArray(itemsToUpdate[i].DUP_Document_Template__c)){
                itemsToUpdate[i].DUP_Document_Template__c=null;
            } 
            if (this.isArray(itemsToUpdate[i].DUP_Counterparty_Contact_Name__c)){
                itemsToUpdate[i].DUP_Counterparty_Contact_Name__c=null;
            } 
            if(itemsToUpdate[i].DUP_Document_Status__c == 'Created'
               && itemsToUpdate[i].DUP_Requested__c){
                itemsToUpdate[i].DUP_Document_Status__c = 'Requested';
            }
	    if(itemsToUpdate[i].DUP_Document_Status__c == 'Requested'
               && !itemsToUpdate[i].DUP_Requested__c){
                itemsToUpdate[i].DUP_Document_Status__c = 'Created';
            }
        }
        }    

        var action = component.get("c.updateDocStore");
        action.setParams({
            "docStoreRecs": itemsToUpdate
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(component.isValid() && state == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Document Request Updated",
                    "type" : "success"
                });
                toastEvent.fire();  
                $A.get('e.force:refreshView').fire();              
            } else {
                console.log('There was a problem : '+JSON.stringify(response.getError()));
            }           
        });
        $A.enqueueAction(action);
    },
    createAddDocumentComponent : function (component,event,helper){
        $A.createComponent 
        (
            "c:DUP_NewDocumentRequest",
            {
                "aura:id":"fileUpload",
                "modalNewDocStore":component.get("v.modalNewDocStore"), 
                "openModal":component.get("v.openModal"), 
                "recordId":component.get("v.recordId"),
            },
            function(newCmp, status, errorMessage)
            {
                if (status === "SUCCESS") 
                {
                    var body = component.get("v.body");
                    body.push(newCmp);
                    component.set("v.body", body);
                }
                else if (status === "ERROR") 
                {
                    console.log("Error occurred from JS: " + errorMessage);
                }
            }
        );
    },
    
    onchange : function(component, event) {
        var action = component.get("c.getLookupList");
        var term = event.getSource().get( "v.value" );
        var obj = event.getSource().getLocalId();

        action.setParams({
            "searchTerm" :  term,
            "objName" : obj
        });
        
        if(term.length > 0){
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log
                if(state === "SUCCESS")  {
                    var result = response.getReturnValue();
                    component.set("v.conList", result);
                    if(term != "" && result.length > 0){
                        var ToOpen = component.find("toOpen");
                        $A.util.addClass(ToOpen, "slds-is-open");
                    }else{
                        var ToOpen = component.find("toOpen");
                        $A.util.removeClass(ToOpen, "slds-is-open");
                    }
                }
                
            });
            
            $A.enqueueAction(action);
        }
    },
    handleEvent : function(component, event) {
        var lookupEventToParent = event.getParam("selectedItem");
        var itemId = event.getParam("itemId");
        var objName = event.getParam("objectName");
        var grpTitle = event.getParam("groupTitle");
        var arrayMapKeys = component.get("v.titleMap");
        var updateMap = [];
        var updateList = [];
        var flag = false;
        for(var key in arrayMapKeys){
            var itemList = arrayMapKeys[key].value ;
            for(var i = 0; i < itemList.length; i++){
                if(JSON.stringify(itemList[i].Id)=='"'+itemId.toString()+'"'){
                    if(objName=='DUP_Document_Template__c'){
                        arrayMapKeys[key].value[i].DUP_Document_Template__c = lookupEventToParent.Id;
                        arrayMapKeys[key].value[i].DUP_Document_Template__r = lookupEventToParent;
                        arrayMapKeys[key].value[i].searchTextTemplate = null;
                        arrayMapKeys[key].value[i].changed = true;
                        component.set("v.selected", true);
                        component.set("v.titleMap",arrayMapKeys);
                        flag = true;
                        break;
                    }
                    else if(objName=='DUP_Counterparty_Contact__c'){
                        arrayMapKeys[key].value[i].DUP_Counterparty_Contact_Name__c = lookupEventToParent.Id;
                        arrayMapKeys[key].value[i].DUP_Counterparty_Contact_Name__r = lookupEventToParent;
                        arrayMapKeys[key].value[i].searchText = null;  
                        arrayMapKeys[key].value[i].changed = true;
                        component.set("v.selected", true);
                        component.set("v.titleMap",arrayMapKeys);
                        flag = true;
                        break;
                    }
                }
            }
            if(flag){
                break;
            }
        }
    },
    
    handleRemoveOnly : function(component, event) {
        var sel = event.getSource().get("v.name");
        var selectedRec = (event.getSource().getLocalId()).toString();
        var itemList = component.get("v.titleMap");
        var flag = false;
        for(var i = 0; i < itemList.length; i++){
            for(var key in itemList[i].value){
                if(itemList[i].value[key].Id==sel.Id){
                    if(selectedRec=='DUP_Document_Template__c'){
                        itemList[i].value[key].DUP_Document_Template__c = null;
                        itemList[i].value[key].DUP_Document_Template__r = null;
                        itemList[i].value[key].searchTextTemplate = '';
                        component.set("v.titleMap", itemList);
                        itemList[i].value[key].changed = true;
                    	flag = true;
                        break;
                    }
                    else if(selectedRec=='DUP_Counterparty_Contact__c'){
                        itemList[i].value[key].DUP_Counterparty_Contact_Name__c = null;
                        itemList[i].value[key].DUP_Counterparty_Contact_Name__r = null;
                        itemList[i].value[key].searchText = '';
                        component.set("v.titleMap", itemList);
                        itemList[i].value[key].changed = true;
                    	flag = true;
                        break;
                    }
                }
            }
            if(flag){
                break;
            }
        }
    },
    
    setChanged : function(component, event, docStoreId) {
        var itemList = component.get("v.titleMap");
        var flag = false;
        for(var i = 0; i < itemList.length; i++){
            for(var key in itemList[i].value){
                if(itemList[i].value[key].Id==docStoreId){
                    itemList[i].value[key].changed = true;
                    flag = true;
                }
            }
            if(flag){
                break;
            }
        }
    }
    
})