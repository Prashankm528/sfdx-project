({  
    setErpId: function(component) {
    	var accFields = component.get("v.accountFields");
        
        //go find the parent up to 3 levels
        if (accFields.Record_Type__c === "Customer") {
            if (accFields.ParentId !== null) {
                if (accFields.Parent.ParentId !== null) {
                    component.set("v.erpId", accFields.Parent.Parent.Account_ERP_ID__c);
                } else {
                    component.set("v.erpId", accFields.Parent.Account_ERP_ID__c);
                }
            } else {
                //this is the parent
                component.set("v.erpId", accFields.Account_ERP_ID__c);
            }
        } else {
            //this is account is Prospect
            component.set("v.errorMsg", $A.get("$Label.c.SFO_OpenText_Prospect_ErrMsg"));
        }
    }
})