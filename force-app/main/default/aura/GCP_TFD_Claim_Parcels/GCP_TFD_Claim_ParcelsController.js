({
    doInit : function(component,event,helper){
    	helper.onLoad(component,event); 
    },
    // For select all Checkboxes 
    selectAll: function(component, event, helper) {
        //get the header checkbox value  
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element 
        var getAllId = component.find("boxPack");
        // If the getAllId is unique[in single record case], find() returns the component. not array   
        if(! Array.isArray(getAllId)){
            if(selectedHeaderCheck == true){ 
                component.find("boxPack").set("v.value", true);
                }else{
                    component.find("boxPack").set("v.value", false);
                }
            }else{
            // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
            // and set the all selected checkbox length in selectedCount attribute.
            // if value is false then make all checkboxes false in else part with play for loop 
            // and select count as 0 
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", true);
                }
                } else {
                      for (var i = 0; i < getAllId.length; i++) {
                          component.find("boxPack")[i].set("v.value", false);
                      }
                  } 
             }  
         },
    
	moveNext : function(component,event,helper){
         // control the next button based on 'currentStep' attribute value    
         var getCurrentStep = component.get("v.currentStep");
            if(getCurrentStep == "1"){
                component.set("v.currentStep", "2");
            }
            //Fetching te pick list values of Cover letter and Supporting letter...
            helper.fetchPickListVal(component, 'GCP_TFD_Cover_Letter__c', 'cLetter');
            helper.fetchPickListVal(component, 'GCP_TFD_Supporting_Letter__c', 'sLetter');        
    },
    
    moveBack : function(component,event,helper){
      // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
         if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
         }
    },
    
    finish : function(component,event,helper){
      // on last step show the alert msg, hide popup modal box by navigating to record page and reset the currentStep attribute  
      component.set("v.currentStep", "1");
      // create var for store record id's for selected checkboxes  
      var parId = [];
      // get all checkboxes 
      var getAllId = component.find("boxPack");
      // If the local ID is unique[in single record case], find() returns the component. not array
         if(! Array.isArray(getAllId)){
             if (getAllId.get("v.value") == true) {
               	 parId.push(getAllId.get("v.text"));
             }
         }else{
         // In a for loop check every checkbox values 
         // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
         for (var i = 0; i < getAllId.length; i++) {
           if (getAllId[i].get("v.value") == true) {
             parId.push(getAllId[i].get("v.text"));
           }
          }
         }
         component.set("v.isOpen", false);
        //alert(parId);
        //checking if atleast 1 parcel record is selected...
        if(parId.length === 0){
            //component.set("v.isOpen", true);
            component.set("v.currentStep", "1");
     		//component.find("box3").set("v.value", false);
            alert('Please select atleast 1 parcel to claim');
        }
        else{
         	var cletter = component.find("cLetter").get("v.value");
        	var sletter = component.find("sLetter").get("v.value"); 
			var discdate;
			if(component.find("discdate").get("v.value") != '')
			{
			discdate = component.find("discdate").get("v.value");
			}
            helper.finishProcess(component,parId,cletter,sletter,discdate);          
        }        
    },
   
   // when user click direactly on step 1,step 2 indicator then showing appropriate step using set 'currentStep'   
    selectFromHeaderStep1 : function(component,event,helper){
        component.set("v.currentStep", "1");
    },
    selectFromHeaderStep2 : function(component,event,helper){
            component.set("v.currentStep", "2");
        	helper.fetchPickListVal(component, 'GCP_TFD_Cover_Letter__c', 'cLetter');
        	helper.fetchPickListVal(component, 'GCP_TFD_Supporting_Letter__c', 'sLetter');
    },
    openModel: function(component, event, helper) {
    // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
      //component.find("box3").set("v.value", false);
   },
    
   closeModel: function(component, event, helper) {
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
})