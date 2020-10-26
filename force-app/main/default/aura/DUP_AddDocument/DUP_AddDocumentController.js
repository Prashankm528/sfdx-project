({
	doInit : function(component, event, helper) {
	   helper.loadRecords(component, event, helper);
	},
    
    doUpdate : function(component, event, helper) {
        helper.doUpdate(component, event, helper);
    },
 
    addRequest : function (component, event, helper) {
        component.set('v.openModal', true);
        component.set('v.modalNewDocStore', true);
        helper.createAddDocumentComponent(component, event, helper);
    },

    openDescription : function (component, event, helper) {
        component.set('v.openModal', true);
        var modal = event.target.parentElement.parentElement.nextSibling;
        $A.util.toggleClass(modal, 'slds-hide');
    },

    closeDescription : function (component, event, helper) {
        component.set('v.openModal', false);
        var modal = event.target.parentElement.parentElement.parentElement;
        $A.util.toggleClass(modal, 'slds-hide');
        helper.setChanged(component, event, modal.id);
    },
    
    displayCertified : function (component, event, helper) {
        var counterCertified = component.get('v.counterCertified');
        var updatedCounterCertified = event.getSource().get('v.checked') ? (counterCertified + 1 ) : (counterCertified -1);
        component.set('v.counterCertified', updatedCounterCertified);        
        var docStoreId = event.target.id;
        helper.setChanged(component, event, docStoreId);
    },
    
    handleNewDocumentEvent : function(component, event, helper) {
        if(event.getParam("isNewDocument")){
            //var itemList = component.get("v.itemList");
            var titleMap = component.get("v.titleMap");
            var docId = event.getParam("newDocStore").Id;
            var groupTitle = event.getParam("newDocStore").DUP_Group_Title__c;
            var contentDoc = event.getParam("contentDocument")
            //itemList.push(event.getParam("newDocStore"));
            component.set("v.contentDocument", contentDoc);
            //component.set("v.itemList", itemList);
            
            var arrayMapKeys = []
            var valueSet = false;
            var uiMap = component.get("v.uiMap");;
            for(var key in titleMap){
                if(titleMap[key].key == groupTitle){
                    (titleMap[key].value).push(event.getParam("newDocStore"));
                    valueSet = true;
                    break;
                }
            }
            
            if(!valueSet){
                arrayMapKeys.push(event.getParam("newDocStore"));
                titleMap.push({key: groupTitle, value: arrayMapKeys});
                var obj = new Object();
                    obj.key = groupTitle;
                    obj.isExpanded = false;
                    uiMap.push(obj);
            }
            component.set("v.uiMap",uiMap);
            component.set("v.titleMap", titleMap);
            
            for(var i = 0; i < titleMap.length; i++){
                for(var key in titleMap[i].value){
                    if(titleMap[i].value[key].Id==docId){
                        helper.addFileList(component, event, helper, titleMap[i].value[key].Id, contentDoc);
                        break;
                    }
                }
            }
        }
        component.set("v.modalNewDocStore", false);
        component.set("v.openModal", false);
        var comp = component.find("fileUpload");
        if(comp!=null)
            comp.destroy();
    },
    previewFile : function(cmp, evt, hlp) {
        var rec_id = evt.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });
    },
    
    onchange : function(component, event, helper) {
        helper.onchange(component, event);
    },
    onFocusOut : function(component, event, helper) {
        const blurTimeout = window.setTimeout(
            $A.getCallback(() => {
                var sel = event.getSource().get("v.name");
                var itemList = component.get("v.titleMap");
                var selected = component.get("v.selected");
                if(selected==false){
                for(var i = 0; i < itemList.length; i++){
                    for(var key in itemList[i].value){
                    	if(itemList[i].value[key].Id==sel.Id){
                            itemList[i].value[key].searchTextTemplate = '';
                            itemList[i].value[key].searchText = '';
                            component.set("v.titleMap", itemList);
                            break;
                		}
                     }
                 }
                 }
                 else{
                 	component.set("v.selected", false);
            	 }
            	 }),
            300
            );
        component.set('v.blurTimeout', blurTimeout);
        
    },
    handleEvent : function(component, event, helper) {
        helper.handleEvent(component, event);
    },
    handleRemoveOnly : function(component, event, helper) {
        helper.handleRemoveOnly(component, event);
    },
    
    handleOnClick: function(component, event, helper) {
        var evTarget = event.currentTarget;
        var sectionId = evTarget.getAttribute("id");
        var sectionDiv = document.getElementById(sectionId.trim()+"divHeader");
        var uiMap = component.get("v.uiMap");
		if(sectionDiv!=null && sectionDiv!='' && sectionDiv!=undefined){
			for(var key in uiMap){
            if(uiMap[key].key==sectionId){
                if(uiMap[key].isExpanded){
                    sectionDiv.removeAttribute('class' , 'slds-section slds-is-open');
                    sectionDiv.setAttribute('class' , 'slds-section');
                    uiMap[key].isExpanded = false;
                    break;
                }
                else{
                    sectionDiv.removeAttribute('class' , 'slds-section');
                    sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
                    uiMap[key].isExpanded = true;
                    break;
                }
            }
        }
        }
        
        component.set("v.uiMap",uiMap);
    },
    setChanged : function(component, event, helper) {
        var docStoreId = event.target.id;
        helper.setChanged(component, event, docStoreId);
        
    },
    
})