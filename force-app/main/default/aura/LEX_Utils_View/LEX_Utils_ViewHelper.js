/* @Author  : Vit Bares
 * @Email   : vit.bares@bluewolfgroup.com
 * @Company : Bluewolf
 * @Created : 03/12/2017
 * This code is the intellectual property of IBM GBS and is not to be used by non-GBS practitioners nor distributed outside of GBS engagements.
 * For full usage guidelines refer to http://ibm.biz/innersourcing-consume-guidelines
*/
({
    handleError: function (errorMessage) {
        this.showToast('Error', 'An Error Occurred: ' + errorMessage, 'error', 'sticky');
    },
    showToast: function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        if (!$A.util.isEmpty(toastEvent)) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type || "other",
                "mode": mode || "dismissible"
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    },
    navigateToSObject: function (sObjectId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        if (navEvt !== undefined) {
            navEvt.setParams({
                "recordId": sObjectId
            });
            navEvt.fire();
        }
        else {
            window.location.href = '/' + sObjectId;
        }
    },
    startSpinner: function (component) {
        var spinner = component.find("ltngSpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    stopSpinner: function (component) {
        var spinner = component.find("ltngSpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})