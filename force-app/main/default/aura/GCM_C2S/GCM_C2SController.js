({
    doInit : function(component, event, helper) {
        // Clean Up Old Record
        console.log('doInit');
        helper.clearTimerClient(component);
        window.tabInfo = [];
    },
    
    onTabCreated : function(component, event, helper) {
        // Tracer
        var newTabId = event.getParam('tabId');
        console.log('Tab Created' + newTabId);
    },
    
    onTabUpdated : function(component, event, helper) {
        // Record Creation
        console.log('Tab Updated' + event.getParam('tabId'));
        var currentTabId = event.getParam('tabId');
        var workspaceAPI = component.find('workspace');        
        if (currentTabId != null) {
            workspaceAPI.getTabInfo({
                tabId : currentTabId
            }).then(function(response) {
                console.log('Title: ' + response.title);
                console.log('Title: ' + response.title.includes("New Case: General Case"));
                console.log('response.recordId: ' + response.recordId);
                
                if (response.title.includes("New Case:") && !response.title.includes("New Case: General Case") && response.recordId==null) {
                    helper.startNewCaseTimerClient(component);
                }
                else if (response.recordId != null) {
                    if(response.recordId.substring(0, 3)=="500"){
                        window.recordId = response.recordId;
                        window.tabInfo[currentTabId] = window.recordId;
                        console.log('Record Id: ' + window.recordId);
                        console.log('Parent Tab Id: ' + response.parentTabId);
                        helper.startTimerClient(component);
                    }
                }
            });
        }
        
    },
    
    onTabFocused : function(component, event, helper) {
        // Highlight Tab
        console.log('Tab Focused: ' + event.getParam('currentTabId'));
        
        var currentTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find('workspace');        
        if (currentTabId != null) {
            workspaceAPI.getTabInfo({
                tabId : currentTabId
            }).then(function(response) {
                
                
                console.log('Title: ' + response.title);
                console.log('Title: ' + response.title.includes("New Case: General Case"));
                if (response.title.includes("New Case:") && !response.title.includes("New Case: General Case") && response.recordId==null) {
                                       helper.stopTimerByCaseClient(component);
                }
                if (response.recordId != null) {
                    if(response.recordId.substring(0, 3)=="500"){
                        window.recordId = response.recordId;
                        window.tabInfo[currentTabId] = window.recordId;
                        console.log('Record Id: ' + window.recordId);
                        console.log('Parent Tab Id: ' + response.parentTabId);
                        helper.startTimerClient(component);
                    }
                }
            });
        }
    },
    
    onTabReplaced : function(component, event, helper) {
        // Tracer
        var replacedTabId = event.getParam("tabId"); 
        var workspaceAPI = component.find("workspace"); 
        workspaceAPI.getTabURL({
            tabId : replacedTabId,
            callback : function(error, response){
                console.log(response); 
            }
        });
    },
    
    onTabRefreshed : function(component, event, helper) {
        // Tracer
        console.log("Tab Refreshed");
        var refreshedTabId = event.getParam("tabId");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo({
            tabId : refreshedTabId
        }).then(function(response) {
            console.log(response);    
        });
    },
    
    onTabClosed : function(component, event, helper) {
        // getTabInfo Won't Work Here
        // Retrieve Tab Information From Memory Instead
        console.log('Tab onTabClosed: ' + event.getParam('currentTabId'));
        
        
        var closedTabId = event.getParam('tabId');
        console.log('Tab closedTabId: ' +closedTabId);
        if (window.tabInfo != null) {
            if (closedTabId in window.tabInfo) {
                window.recordId = window.tabInfo[closedTabId];
                console.log(' window.recordId: ' + window.recordId);
                
                if(window.recordId.substring(0, 3)=="500"){
                    helper.stopTimerByCaseClient(component);
                }
                window.tabInfo[closedTabId] = null;
            }
            else 
            {
                console.log('New Case closed Tab');
                helper.NewCaseclearTimerClient(component);
            }
        }
        else 
        {
            console.log('New Case closed Tab1');
            helper.NewCaseclearTimerClient(component);
        }
    },
})