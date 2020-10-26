/**
 * Created by Alessandro Miele on 2019-10-18
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
    }
    
});