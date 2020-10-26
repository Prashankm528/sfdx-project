({
    doInit : function(component) {
	    var action = component.get('c.getAccounts');
        component.set("v.showSpinner", true);
        
        //action.setStorable();
        
        action.setParams({
            "fav": component.get('v.showFavouritesOnly'),
            "bu": component.get('v.showBusinessUnitOnly')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (returnValue) {
                    component.set("v.accounts", returnValue);
                    component.set("v.showSpinner", false); 
                }
            }
        });
        
        $A.enqueueAction(action);
        
        this.resetSearch(component);
        component.set("v.selectAll", false);
        component.set("v.countOfRequested", 0);
    },
    
    request : function(component) {
        var action = component.get('c.requestAccounts');
        var accounts = component.get('v.accounts');
        var requestAccounts = [];
        var toastMsg;
        
        for (var i = 0; i < accounts.length; i++) {
            if (accounts[i].newRequest === true) {
                requestAccounts.push(accounts[i]);
            }
		}
        
        if (requestAccounts.length > 0) {
            if (requestAccounts.length == 1) {
            	toastMsg = $A.get("$Label.c.CALCF_QBR_RequesterToastSingular");
        	} else {
            	toastMsg = $A.get("$Label.c.CALCF_QBR_RequesterToastPlural");
        	}
            
            action.setParams({
                "accounts": requestAccounts
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "success",
                            "title": "Success!",
                            "message": toastMsg
                        });
                        toastEvent.fire();
                        $A.get("e.force:refreshView").fire();
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
    updateCount : function(component) {
        var accounts = component.get("v.accounts");
        var count = 0;
        
        for ( var i = 0; i < accounts.length; i++) {
            if (accounts[i].newRequest) {
                count++;
            }
        }
        
        component.set("v.countOfRequested", count);
    },
    
    selectAccount : function(component, event) {
        component.set("v.searchLocked", true);
        
        var accounts = component.get("v.accounts");
        var searchedAccounts = component.get("v.searchedAccounts");
        var selectedElement = event.currentTarget;
        
        for (var i = 0; i < searchedAccounts.length; i++) {
            if (selectedElement.id === searchedAccounts[i].Id) {
                accounts.push(searchedAccounts[i]);
            }
        }

        component.set("v.accounts", accounts);
        this.resetSearch(component);
    },
    
    toggleSelect : function(component) {
        var toggle = component.get("v.selectAll");
        var accounts = component.get("v.accounts");
        
        for ( var i = 0; i < accounts.length; i++) {
            accounts[i].newRequest = toggle;
        }
        
        component.set("v.accounts", accounts);
        this.updateCount(component);
    },
    
    search : function(component) {
        var searchTerm = component.get("v.searchTerm");

        if (searchTerm && searchTerm.length > 1) {
            var action = component.get("c.searchAccounts");
            
            action.setParams({
                "key": searchTerm
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    
                    if (returnValue) {
                        var accounts = component.get("v.accounts");
                        var keepFlag = true;
                        var filteredSearch = [];
                        
                        // Filter out already listed accounts
                        for (var i = 0; i < returnValue.length; i++) {
                            for (var j = 0; j < accounts.length; j++) {
                                if (returnValue[i].Id === accounts[j].Id) {
                                    keepFlag = false;
                                }
                            }
                            
                            if (keepFlag) {
                                filteredSearch.push(returnValue[i]);
                            }
                            
                            keepFlag = true;
                       	}
                        
                        component.set("v.searchedAccounts", filteredSearch);
                    } else {
						component.set("v.searchedAccounts", null);
                    }
                }
            });
            
            $A.enqueueAction(action);   
            
        } else {
			component.set("v.searchedAccounts", null);
        }

        if (component.get("v.searchLocked")) {
            component.set("v.searchLocked", false);
        }
    },
    
    resetSearch : function(component) {
        component.set("v.searchedAccounts", null);
        component.set("v.searchTerm", null);
        component.set("v.searchLocked", false);
    }
})