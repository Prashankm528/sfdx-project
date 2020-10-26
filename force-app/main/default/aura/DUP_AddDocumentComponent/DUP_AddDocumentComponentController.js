/**
 * Created by Mayuri Basutkar on 2019-09-01.
 */
({
    doInit: function(cmp, evt, hlp) {
        hlp.getAllDocumentStore(cmp,evt,hlp);
    },

    sendCommunication: function(cmp, evt, hlp) {
        hlp.sendCommunicationHelper(cmp,evt,hlp);
    },

    sendRejectionCommunication: function(cmp, evt, hlp) {
        hlp.sendRejectionCommunicationHelper(cmp,evt,hlp);
    },
    openModal: function(cmp, evt, hlp) {
        cmp.set("v.modalCPChange",true);
    },
    closeModal: function(cmp, evt, hlp) {
        cmp.set("v.modalCPChange",false);
    },
    changeCPContact: function(cmp, evt, hlp) {
        hlp.changeCPContact(cmp,evt);
    },
    handleEvent : function(component, event, helper) {
        helper.handleEvent(component, event);
    },
    handleRemoveOnly : function(component, event, helper) {
        helper.handleRemoveOnly(component, event);
    },

    onchange : function(component, event, helper) {
        helper.onchange(component, event);
    },
    onFocusOut : function(component, event, helper) {
        const blurTimeout = window.setTimeout(
            $A.getCallback(() => {
                
            	 }),
            300
            );
        component.set('v.blurTimeout', blurTimeout);
        
    }
})