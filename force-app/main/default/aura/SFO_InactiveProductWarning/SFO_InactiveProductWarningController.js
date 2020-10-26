({
    doInit : function(component, event, helper) {
        var showWarning = component.get("c.showWarning");
        showWarning.setParams({"opportunityId": component.get("v.recordId")});

        showWarning.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var inactiveProducts = response.getReturnValue();

                if (!Array.isArray(inactiveProducts)) {
                    console.log('Inavlid return value expected array.');
                    return;
                }

                if (inactiveProducts.length === 0) {

                    //There are no inactive products
                    component.set("v.warningType", 0);
                } else if (inactiveProducts.length === 1) {

                    //There is one inactive priduct
                    component.set("v.productNames", inactiveProducts);
                    component.set("v.warningType", 1);
                } else if (inactiveProducts.length <= 5) {

                    //There are up to 5 inactive products
                    component.set("v.productNames", inactiveProducts);
                    component.set("v.warningType", 2);
                } else if (inactiveProducts.length > 5) {

                    //there are more then 5 inactive products
                    //show only first 5 so the message is not too big...
                    var productNames = [];
                    for (var i = 0; i<5; i++) {
                        productNames.push(inactiveProducts[i]);
                    }

                    component.set("v.productNames", productNames);
                    component.set("v.warningType", 3);
                }

            } else {
                console.log('showWarning call failed: ' + state);
            }
        });
        $A.enqueueAction(showWarning);
    }
})