({
	 onSumAmountChange : function(component,event,helper){
         if(event.getParams('sumAmount')) 
             component.set('v.sumAmount',event.getParams('sumAmount'));
          
    },
    /** onfocus event on look up search text box  **/
    onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open'); 
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
         helper.searchHelper(component,event,getInputkeyWord,helper);
    },
    /** onblur event on look up search text box **/
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    /** Key press event on look up search text box  **/
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
        console.log('getInputkeyWord'+getInputkeyWord); 
        if( getInputkeyWord.length > 0 ){
             var forOpen = component.find("searchRes");
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord,helper);
        }
        else{  
           //  component.set("v.listOfSearchRecords", null ); 
             //var forclose = component.find("searchRes");
              // $A.util.addClass(forclose, 'slds-is-close');
              // $A.util.removeClass(forclose, 'slds-is-open');
               helper.searchHelper(component,event,getInputkeyWord,helper);
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,helper) {
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );
        
         var fieldName= component.get('v.fieldName');
         var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
        fieldsMetaDatamap[fieldName].LookVal = null;
        fieldsMetaDatamap[fieldName].LookValId = null;
        fieldsMetaDatamap[fieldName].Fieldvalue = null;
        component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
   
        
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedRecord = event.getParam("recordByEvent");
         var fieldName= component.get('v.fieldName');
        var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
        fieldsMetaDatamap[fieldName].LookVal = selectedRecord.Name;
        fieldsMetaDatamap[fieldName].LookValId = selectedRecord.Id;
        fieldsMetaDatamap[fieldName].Fieldvalue = selectedRecord.Id;
        component.set('v.fieldsMetaDatamap',fieldsMetaDatamap);
       
	   component.set("v.selectedRecord" , selectedRecord);
       component.set('v.SNoteFlg',true);
       helper.setLookUpValue(component, event, helper);

      
	},
     /** set look values for existing value **/ 
    setLookUpValue :  function(component, event, helper) {
           var forclose = component.find("lookup-pill");  
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
    },
})