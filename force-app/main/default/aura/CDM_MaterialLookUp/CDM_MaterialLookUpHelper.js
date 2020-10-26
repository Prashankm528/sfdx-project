({
    /** search help for send apex call out get look up values **/
	searchHelper : function(component,event,getInputkeyWord,helper) {
	  // call the apex class method 
		var PreviousSearchKeyWord = component.get('v.PreviousSearchKeyWord');
        console.log('PreviousSearchKeyWord'+PreviousSearchKeyWord);
		 if(PreviousSearchKeyWord != getInputkeyWord) {
           helper.searchLookUp(component, getInputkeyWord);
         } else{
             console.log('getInputkeyWord'+getInputkeyWord);
            if(getInputkeyWord == '' || getInputkeyWord == undefined  || getInputkeyWord == null) {
          		helper.searchLookUp(component, getInputkeyWord);
            } else {
                console.log('getInputkeyWord1'+getInputkeyWord);
               component.set("v.listOfSearchRecords", component.get('v.PreviousListOfSearchRecords'));
               }
         }
    
	}, 
  
  /** search look addional helper for searchHelper  **/  
    searchLookUp : function(component, getInputkeyWord) {
       //alert('searchLookUp');
      var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
       // if(fieldsMetaDatamap)
        var salesOrg = fieldsMetaDatamap['CDM_Sales_Organisation__c'].Fieldvalue;
        var dChannel = fieldsMetaDatamap['CDM_Distribution_Channel__c'].Fieldvalue;
        console.log('salesOrg'+salesOrg);
        console.log('salesOrg'+dChannel);
         var action = component.get("c.getMaterials");
         action.setParams({
            'sobjName' : 'CDM_Material__c',
            'searchKey' : getInputkeyWord,
             'salesOrg' : salesOrg,
             'dChannel' : dChannel
             });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if(storeResponse) {
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                } else 
                    component.set("v.Message", 'No Result Found...');
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
                component.set('v.PreviousListOfSearchRecords',storeResponse);
                component.set('v.PreviousSearchKeyWord',getInputkeyWord);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    }
})