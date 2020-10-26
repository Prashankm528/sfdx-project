({
    /** doInit system event  **/
	doInit : function(component, event, helper) {
     
		var fieldsMetaDatamap = component.get('v.fieldsMetaDatamap');
     
       var records = [];
        if(fieldsMetaDatamap) {
            for(var key in fieldsMetaDatamap) {
                if(fieldsMetaDatamap[key]) {
                    if(fieldsMetaDatamap[key].DataType == 'DATE' && fieldsMetaDatamap[key].Fieldvalue){
                        var dtval = fieldsMetaDatamap[key].Fieldvalue.split(" ");
                        if(dtval.length>0) {
                            fieldsMetaDatamap[key].Fieldvalue = dtval[0];
                        }
                        
                    }
                }
                records.push(fieldsMetaDatamap[key]);
            } 
                
                component.set('v.fieldsMetaData',records);
            }
        
			       
	},
    /* record edit method **/
    editRecord : function(component, event, helper) {
     
       component.set('v.viewRecord',false);
        var recordId = component.get('v.recordId');
   
        var appEvent = $A.get("e.c:CDM_HideSubmitBtnEvt");
		appEvent.setParams({ 'recordId' : recordId,
                            'btnFlag' : true,
                           	});
		appEvent.fire();

       
        
    },
})