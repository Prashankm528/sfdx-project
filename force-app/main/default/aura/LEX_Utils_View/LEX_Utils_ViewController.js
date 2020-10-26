/* @Author  : Vit Bares
 * @Email   : vit.bares@bluewolfgroup.com
 * @Company : Bluewolf
 * @Created : 03/12/2017
 * This code is the intellectual property of IBM GBS and is not to be used by non-GBS practitioners nor distributed outside of GBS engagements.
 * For full usage guidelines refer to http://ibm.biz/innersourcing-consume-guidelines
*/
({
    handleError: function (component, event, helper) {
        var params = event.getParams().arguments;
        var errorMessage = params.errorMessage;
        helper.handleError(errorMessage);
    },
    navigateToSObject: function (component, event, helper) {
        var params = event.getParams().arguments;
        var sObjectId = params.sObjectId;
        helper.navigateToSObject(sObjectId);
    },
    showToast: function (component, event, helper) {
        var params = event.getParams().arguments;
        var title = params.title;
        var message = params.message;
        var type = params.type;
        var mode = params.mode;
        helper.showToast(title, message, type, mode);
    },
    startSpinner: function (component, event, helper) {
        helper.startSpinner(event.getParams().arguments.component);
    },
    stopSpinner: function (component, event, helper) {
        helper.stopSpinner(event.getParams().arguments.component);
    }
})