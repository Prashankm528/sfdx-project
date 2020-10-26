({
    doInit: function(component, event, helper) {
			helper.getOptions(component);
			helper.getCommodityOptions(component);

	},

	createCase: function(component, event, helper) {
		const theCase = component.get("v.newCase");

	    const helpOption = component.find("helpId");
        
        const helpOptionValue = helpOption.get("v.value");
        const customerEmail = component.find("customerEmailId");
        const customerEmailValue = customerEmail.get("v.value");
 
        const emailAddress = component.find("emailId");
		const emailValue = emailAddress.get("v.value");
		
        const commmodity = component.find("commodityId");
        const commmodityValue = commmodity.get("v.value");

		if (helpOptionValue && emailValue && commmodityValue && customerEmailValue) 
		{
			helper.insertCase(component, JSON.stringify(theCase));
        }
		else 
		{
			helper.alertInvalidFields(component, helper);
		}
	
	}
})