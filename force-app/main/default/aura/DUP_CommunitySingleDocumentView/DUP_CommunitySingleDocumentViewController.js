/*****************************************************************************************
*       Date:        20Set2019
*       Author:      Alessandro Miele - IBM
*       Description: Js Controller for DUP_CommunitySingleDocumentView
*****************************************************************************************/
({
    doInit : function(cmp, evt, hlp) {
        hlp.loadFile(cmp,evt,hlp);
    },
	 expandComp: function (cmp, evt, hlp) {
        //added by Ajay for expanding the section upon button click
        var expand = cmp.get("v.expand");
        if (expand) {
            var sectionDiv = cmp.find('sectionDiv');
            $A.util.addClass(sectionDiv, 'slds-is-open');
            var toggleText = cmp.find('linksSection');
            $A.util.addClass(toggleText, 'toggle');
        }
       else{
            // var sectionDiv = cmp.find('sectionDiv');
            // $A.util.toggleClass(sectionDiv, 'slds-is-open');
            // var toggleText = cmp.find('linksSection');
            // $A.util.toggleClass(toggleText, 'toggle');
            hlp.toggleHelper(cmp);
        }
    },

    toggleSection : function(cmp, evt, hlp) {
        // var sectionDiv = cmp.find('sectionDiv');
        // $A.util.toggleClass(sectionDiv, 'slds-is-open');
        // var toggleText = cmp.find('linksSection');
        // $A.util.toggleClass(toggleText, 'toggle');
        hlp.toggleHelper(cmp);
    },

    refreshView : function(cmp, evt, hlp) {
        hlp.shareFileWithAgent(cmp, evt, hlp);
        hlp.refreshListFile(cmp, evt, hlp);
    },

    openDescription : function (component, event, helper) {
        component.set('v.openModal', true);
    },

    closeDescription : function (component, event, helper) {
        component.set('v.openModal', false);
    },
    openComments : function (component, event, helper) {
        component.set('v.openModal2', true);
    },

    closeComments : function (component, event, helper) {
            component.set("v.document.DUP_CPcomments__c",component.get("v.cp_Comments"));
            component.set('v.openModal2', false);
    },

    addComments: function (component, event, helper) {
        helper.addComments(component, event);
    }
    
});