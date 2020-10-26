({
	createComp : function(component) {
		$A.createComponent(
            "lightning:flow",
            {
                "aura:id": "findableAuraId",
                
            },
            function(flowCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    flowCmp.startFlow("GCM_Case_Timer_Flow");
                    body.push(flowCmp);
                    targetCmp.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
	}
})