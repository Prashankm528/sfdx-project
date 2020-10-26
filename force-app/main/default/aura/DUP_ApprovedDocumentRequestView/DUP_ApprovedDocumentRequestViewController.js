/**
 * Created by Alessandro Miele on 2019-10-18.
 */
({
    doInit: function(cmp, evt, hlp) {
        hlp.getAllDocumentStore(cmp,evt,hlp);
    },

    sendAllToSP: function(cmp, evt, hlp) {
        hlp.sendAllFilesToSP(cmp,evt,hlp);
    }    
})