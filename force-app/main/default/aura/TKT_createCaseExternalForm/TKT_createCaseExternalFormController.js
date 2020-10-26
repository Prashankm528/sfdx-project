({
    doInit: function(component, event, helper) {
			helper.getOptions(component);
			helper.getBusinessOptions(component);

	},

	createCase: function(component, event, helper) {
		const theCase = component.get("v.newCase");

	    const helpOption = component.find("helpId");
        const helpOptionValue = helpOption.get("v.value");
 
		const firstName = component.find("fname");
		const firstNameValue = firstName.get("v.value");

		const lastName = component.find("lname");
        const lastNameValue = lastName.get("v.value");

        const emailAddress = component.find("emailId");
		const emailValue = emailAddress.get("v.value");
		
        const company = component.find("companyId");
        const companyValue = company.get("v.value");

        const business = component.find("businessId");
        const businessValue = business.get("v.value");

        const marketer = component.find("marketerId");
        const marketerValue = marketer.get("v.value");


		if (helpOptionValue && firstNameValue && lastNameValue && 
			emailValue && companyValue && businessValue && marketerValue) 
		{
			helper.insertCase(component, JSON.stringify(theCase));
        }
		else 
		{
			helper.alertInvalidFields(component, helper);
		}
	
	}
})