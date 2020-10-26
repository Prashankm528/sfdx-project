({
    /** doInit system event  **/
   doInit : function(component,event,helper){
       var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
       var fieldName = component.get('v.fieldName');
     
       if(fieldsMetaDatamap) 
           if(fieldsMetaDatamap[fieldName].LookVal) {
               var selectedRecord = component.get('v.selectedRecord');
               selectedRecord.CDM_Material__c = fieldsMetaDatamap[fieldName].LookVal;
               console.log('LookVal'+fieldsMetaDatamap[fieldName].LookVal);
               selectedRecord.Id = fieldsMetaDatamap[fieldName].LookValId;
               component.set('v.selectedRecord',selectedRecord);
               helper.setLookUpValue(component,event,helper);
           }
        
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
         var cmpEvent = component.getEvent("CDM_MaterialTypeEvt");
        component.set('v.selectedMaterial',null);
        if (cmpEvent) {
            cmpEvent.setParams({ material :   null});
           cmpEvent.fire();
        }
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedRecord = event.getParam("recordByEvent");
         var fieldName= component.get('v.fieldName');
        var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
        fieldsMetaDatamap[fieldName].LookVal = selectedRecord.CDM_Material__c;
        fieldsMetaDatamap[fieldName].LookValId = selectedRecord.Id;
        fieldsMetaDatamap[fieldName].Fieldvalue = selectedRecord.Id;
        component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
       console.log(JSON.stringify(fieldsMetaDatamap));
	   component.set("v.selectedRecord" , selectedRecord); 
         helper.setLookUpValue(component, event, helper);
         component.set('v.selectedMaterial',selectedRecord);
      var cmpEvent = component.getEvent("CDM_MaterialTypeEvt");
        if (cmpEvent) {
            cmpEvent.setParams({ material :  selectedRecord});
            cmpEvent.fire();
        }
      
	},
    close :  function(component, event, helper) {
       // component.set('v.SNoteFlg',false);
        
    },
    
})