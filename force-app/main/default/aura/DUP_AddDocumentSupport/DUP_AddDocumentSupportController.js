/**
 * Created by Mayuri Basutkar on 2019-09-03
 * Updated by Alessandro Miele
 */

({
    doInit: function(cmp, evt, hlp) {
        hlp.loadFile(cmp,evt,hlp);
    },

    toggleSection: function(cmp, evt, hlp) {
        var sectionDiv = cmp.find('sectionDiv');
        $A.util.toggleClass(sectionDiv, 'slds-is-open');
        console.log('in toggle'+cmp.find('sectionDiv'));
        var toggleText = cmp.find('linksSection');
        $A.util.toggleClass(toggleText, 'toggle');
    },

    openDescription : function (component, event, helper) {
        component.set('v.openModal', true);
    },
    
    openComments : function (component, event, helper) {
        helper.toshowornot(component, event, helper);
        component.set('v.openModalComments', true);
          
    },

    closeDescription : function (component, event, helper) {
        component.set('v.openModal', false);
        component.set('v.openModalComments', false);
    }
    
});