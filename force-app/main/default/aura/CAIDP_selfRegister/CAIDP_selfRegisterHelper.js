({
    qsToEventMap: {
        'startURL'  : 'e.c:CAIDP_setStartUrl'
    },
    
    setCookie: function (cname, cvalue) {
        document.cookie = cname + "=" + cvalue + '; path=/;';
    },
    
    getCookie: function (cname) {
        var name = cname + "=";
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
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
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
            if (sParameterName[0] === sParam) {
                if (sParameterName[1] === undefined) {
                    return sParam === 'language' ? 'en_US' : '';
                }
                return sParameterName[1];
            }
        }
        return '';
    },
    
    handleSelfRegisteration: function (component, event, helper) {
        
        var termsAccepted = component.get("v.acceptedPrivacies");
        if (termsAccepted) {
            var emailParam = component.get("v.emailInput");
            var accountId = component.get("v.accountId");
            var regConfirmUrl = component.get("v.regConfirmUrl");
            var country = component.get("v.selectedCountry");
            var firstname = component.find("firstname").get("v.value");
            var lastname = component.find("lastname").get("v.value");
            //var email = (emailParam) ? emailParam : component.find("email").get("v.value");
            var includePassword = component.get("v.includePasswordField");
            var password = component.find("password").get("v.value");
            var confirmPassword = component.find("confirmPassword").get("v.value");
            var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
            var startUrl = component.get("v.startUrl");
            var language = this.getUrlParameter('language');
            console.log('language: ' + language);
            startUrl = decodeURIComponent(startUrl);
            
            // anna's code
            var countryCode = component.get("v.codeInput");
            var phoneNumber = component.get("v.phoneInput");
            var fullEmail = (emailParam) ? emailParam : component.get("v.emailInput");
            
            
            if(phoneNumber != null) {
                var actionPhone = component.get("c.selfRegisterPhone");
                actionPhone.setParams({firstname:firstname,lastname:lastname, phoneNumber:phoneNumber,
                                       countryCode:countryCode, country:country, language:language,
                                       password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, 
                                       extraFields:extraFields, startUrl:startUrl, includePassword:includePassword});
                actionPhone.setCallback(this, function(a) {
                    var rtnValue = a.getReturnValue();
                    if (rtnValue !== null) {
                        component.set("v.errorMessage",rtnValue);
                        component.set("v.showError",true);
                    }
                    else {
                        this.deleteCookie("fixedEmail");
                        this.deleteCookie("startUrl");
                    }
                });
                $A.enqueueAction(actionPhone);
            } else if (fullEmail != null) {
                var actionEmail = component.get("c.selfRegister");
                actionEmail.setParams({firstname:firstname,lastname:lastname,email:fullEmail, country:country, language:language,
                                  password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, extraFields:extraFields, startUrl:startUrl, includePassword:includePassword});
                actionEmail.setCallback(this, function(a) {
                    var rtnValue = a.getReturnValue();
                    if (rtnValue !== null) {
                        component.set("v.errorMessage",rtnValue);
                        component.set("v.showError",true);
                    }
                    else {
                        this.deleteCookie("fixedEmail");
                        this.deleteCookie("startUrl");
                    }
                });
                $A.enqueueAction(actionEmail);
            }
            
        }
        else {
            component.set("v.errorMessage", component.get("v.notAcceptedError"));
            component.set("v.showError",true);
        }
    },
    
    getExtraFields : function (component, event, helper) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCountries : function (component, event, helper) {
        var action = component.get("c.getCountriesPicklist");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.allCountries', rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    filterCountries : function (component, event, helper) {
        
        var currCountries = [];
        var mask = event.target.value;
        
        function containsMask(value) {
            return value.toLowerCase().startsWith(mask.toLowerCase());
        }
        
        if (mask) {
            var allCountries = component.get("v.allCountries");
            currCountries = allCountries.filter(containsMask).slice(0,5);
        }
        component.set('v.countries', currCountries);
    },
})