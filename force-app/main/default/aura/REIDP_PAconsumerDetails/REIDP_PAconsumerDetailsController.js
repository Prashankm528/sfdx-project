({
    prepareWalletAction: function (component, event, helper) {
    	helper.togglePrompt(component, event);
        component.set("v.chosenAction",  event.getSource().get("v.label"));
	},
    performWalletAction: function(component, event, helper) {
        var chosenAction = component.get("v.chosenAction");
        if(chosenAction=='Disable Wallet') {
           helper.disableWallet(component, event);
            helper.togglePrompt(component, event);
        }
         if(chosenAction=='Enable Wallet') {
           helper.enableWallet(component, event);
             helper.togglePrompt(component, event);
        }
        if(chosenAction=='Delete Wallet') {
           helper.deleteWallet(component, event);
           helper.togglePrompt(component, event);
        }
    },
    
    cancellWalletAction: function (component, event, helper) {
    	helper.togglePrompt(component, event);
        component.set("v.chosenAction",  "");
	}
    
})