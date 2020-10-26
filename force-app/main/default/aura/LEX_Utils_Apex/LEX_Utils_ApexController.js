/* @Author  : Vit Bares
 * @Email   : vit.bares@bluewolfgroup.com
 * @Company : Bluewolf
 * @Created : 03/12/2017
 * @Description: Controller
 * This code is the intellectual property of IBM GBS and is not to be used by non-GBS practitioners nor distributed outside of GBS engagements.
 * For full usage guidelines refer to http://ibm.biz/innersourcing-consume-guidelines
*/
({
    callApex: function (component, event, helper) {
        // load parameters passed by caller component
        var params = event.getParams().arguments;
        //console.log('params:', params);
        var callerComponent = params.component;
        var controllerMethod = params.controllerMethod;
        var actionParameters = params.actionParameters;
        var successCallback = params.successCallback;
        var callbackParams = params.callbackParams;
        // call implementation of Apex action call
        helper.callApex(component, callerComponent, controllerMethod, actionParameters, successCallback, callbackParams);

    }
})