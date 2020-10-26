({
    
    qsToEventMap: {
        'startURL'  : 'e.c:CAIDP_setStartUrl'
    },
    
    setCookie: function (cname, cvalue) {
        document.cookie = cname + "=" + cvalue + '; path=/;';
    },
    
    getCookie: function (cname) {
        var name = cname + "=";
        // var decodedCookie = decodeURIComponent(document.cookie);
        var ca = document.cookie.split(';');
        for(var i = 0; i <ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    },
    
    deleteCookie: function (cname) {
        document.cookie = cname +'=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    },
    
    getUrlParameter: function (sParam) {
        var sPageURL = window.location.search.substring(1),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
            if (sParameterName[0] === sParam) {
                return (sParameterName[1] === undefined) ? '' : sParameterName[1];
            }
        }
        return '';
    },
    
    handleLogin: function (component, event, helpler) {
        var password = component.find("password").get("v.value");
        var actionPhone = component.get("c.loginPhone");
        var actionEmail = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        startUrl = decodeURIComponent(startUrl);
        
        // check if username is phone number or email
        // if username is numberic(phone number) returns TRUE
        var tab = component.get("v.tabId");
        if (tab == 'email') {
            var email = component.get("v.emailInput");
            actionEmail.setParams({username:email, password:password, startUrl:startUrl});
            actionEmail.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                }
                else {
                    this.deleteCookie("startUrl");
                }
            });
            $A.enqueueAction(actionEmail);
        } else if (tab == 'phone') {
            var countryCode = component.get("v.codeInput");
            var phoneNumber = component.get("v.phoneInput");
            actionPhone.setParams({countryCode: countryCode, phoneNumber:phoneNumber, password:password, startUrl:startUrl});
            actionPhone.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                }
                else {
                    this.deleteCookie("startUrl");
                }
            });
            $A.enqueueAction(actionPhone);
        }
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    }
})