({
    /** doInit system event  **/
   doInit : function(component,event,helper){
       var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
       var fieldName = component.get('v.fieldName');
     
       if(fieldsMetaDatamap) 
           if(fieldsMetaDatamap[fieldName].LookVal) {
               var selectedRecord = component.get('v.selectedRecord');
               selectedRecord.Name = fieldsMetaDatamap[fieldName].LookVal;
               selectedRecord.Id = fieldsMetaDatamap[fieldName].LookValId;
               selectedRecord.CDM_Supporting_Notes__c = fieldsMetaDatamap[fieldName].SupportingNotes;
               component.set('v.selectedRecord',selectedRecord);
               helper.setLookUpValue(component,event,helper);
           }
       console.log('fieldsMetaDatamap'+JSON.stringify(fieldsMetaDatamap));
        
   },
    
    /** onfocus event on look up search text box  **/
    onfocus : function(component,event,helper){
        helper.onfocus(component,event,helper);
     
    },
    /** onblur event on look up search text box **/
    onblur : function(component,event,helper){       
       
        helper.onblur(component,event,helper);
    },
    
    /** Key press event on look up search text box  **/
    keyPressController : function(component, event, helper) {
      helper.keyPressController(component, event, helper);

	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,helper) {
        helper.clear(component,event,helper);
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedRecord = event.getParam("recordByEvent");
        var fieldName= component.get('v.fieldName');
        var country = component.get("v.country");
        var requestType = component.get("v.requestType");
        var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
        fieldsMetaDatamap[fieldName].LookVal = selectedRecord.Name;
        fieldsMetaDatamap[fieldName].LookValId = selectedRecord.Id;
        fieldsMetaDatamap[fieldName].Fieldvalue = selectedRecord.Id;
        component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
        
        component.set("v.selectedRecord" , selectedRecord);
        var action = component.get("c.getSupportingNotes");
        action.setParams({
            "ntId" : selectedRecord.CDM_Approver_NTID__c,
            "reqType" : requestType
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                  var res = response.getReturnValue();
                console.log(JSON.stringify(res));
                if(res) {
                    selectedRecord.CDM_Supporting_Notes_Credit__c = res.SupportingNotes_SD + ';' + res.SupportingNotes_RC; 
                    selectedRecord.CDM_Supporting_Notes_Debit__c = res.SupportingNotes_SG; 
                }
             }
            if(country != 'Australia' && country != 'New Zealand') 
                component.set('v.SNoteFlg',true);
        
        });
        
          $A.enqueueAction(action);
        
        helper.setLookUpValue(component, event, helper);
        
        
    },
    close :  function(component, event, helper) {
        component.set('v.SNoteFlg',false);
        
    },
    
})