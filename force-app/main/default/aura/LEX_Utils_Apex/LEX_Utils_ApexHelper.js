/* @Author  : Vit Bares
 * @Email   : vit.bares@bluewolfgroup.com
 * @Company : Bluewolf
 * @Created : 03/12/2017
 * This code is the intellectual property of IBM GBS and is not to be used by non-GBS practitioners nor distributed outside of GBS engagements.
 * For full usage guidelines refer to http://ibm.biz/innersourcing-consume-guidelines
*/
({
    callApex: function (thisComponent, callerComponent, controllerMethod, actionParameters, successCallback, callBackParams) {

        var action = callerComponent.get(controllerMethod);
        if (!$A.util.isEmpty(actionParameters)) {
            action.setParams(actionParameters);
        }

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('callbackparams', callBackParams);
                successCallback(callerComponent, response.getReturnValue(), callBackParams);
            }
            else {
                this.handleNotSuccessResponse(thisComponent, response);
            }
        });

        $A.enqueueAction(action);
    },
    handleNotSuccessResponse: function (thisComponent, response) {
        var state = response.getState();
        var lexUtilsView = thisComponent.find('LEX_Utils_View');
        var evt = thisComponent.getEvent('apexCallError');
        if (state === "INCOMPLETE") {
            lexUtilsView.handleError('There has been problem with connection. ' +
                'Please make sure you are connected to network and try again');
        }
        else if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " +
                        errors[0].message);
                    evt.setParams({"message":errors[0].message});
                    lexUtilsView.handleError(errors[0].message);
                }
            } else {
                lexUtilsView.handleError('There has been unknown error, please try again');
            }
        }
        else {
            console.log('Something odd happened');
        }
        evt.fire();

    }
})