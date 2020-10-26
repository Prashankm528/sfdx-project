/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 10/2018
*
* Description: Changes URL of login/ForgotPassword/SelfRegister pages.
**/

public class REIDP_CustomLanguagePickerController {
    
    public class SelectOption {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Boolean isDefault;
        
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    @AuraEnabled
    public static List<SelectOption> getCommunityLanguages() {
        String community = 'BP';
        List<SelectOption> result = new List<SelectOption>();
        
        if(Network.getNetworkId() != null) {
            community = [SELECT Id, UrlPathPrefix 
                         FROM Network 
                         WHERE Id = :Network.getNetworkId()].UrlPathPrefix;
        }
        
        
        //Getting language Labels
        Map<String, String> valueToLabel = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = REIDP_Community_Language__mdt.Language__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : ple) {
            valueToLabel.put(f.getValue(), f.getLabel());
        }
        
        for (REIDP_Community_Language__mdt lang : [SELECT MasterLabel, Language__c 
                                                   FROM REIDP_Community_Language__mdt
                                                   WHERE Community__c = :community ORDER BY MasterLabel DESC]) {
			result.add(new SelectOption(lang.Language__c, valueToLabel.get(lang.Language__c)));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static String checkLanguageUrl(String urlPath) {
        
        if(urlPath.removeEnd('/').equals(String.valueOf(Network.getLoginUrl(Network.getNetworkId())))) {
            return 'Login';
        } else if(urlPath.equals(String.valueOf(Network.getSelfRegUrl(Network.getNetworkId())))) {
            return 'SelfRegister';
        } else if(urlPath.equals(String.valueOf(Network.getLoginUrl(Network.getNetworkId())+'/ForgotPassword'))) {
            return 'ForgotPassword';
        }
        
        return null;
    }
    
    @AuraEnabled
    public static void changeLanguageUrlLogin(String language, String startUrl, String urlPath) {
        PageReference pr = new PageReference(urlPath);
        if(!Test.isRunningTest()) {
            pageReferenceChangeLanguage(new PageReference(Network.getLoginUrl(Network.getNetworkId())), language, startUrl);
        }
        
    }
    
    @AuraEnabled
    public static void changeLanguageUrlSelfRegister(String language, String startUrl, String urlPath) {
        PageReference pr = new PageReference(urlPath);
        if(!Test.isRunningTest()) {
            pageReferenceChangeLanguage(new PageReference(Network.getSelfRegUrl(Network.getNetworkId())), language, startUrl);
        }
    }
    
    @AuraEnabled
    public static void changeLanguageUrlForgotPassword(String language, String startUrl, String urlPath) {
        PageReference pr = new PageReference(urlPath);
        if(!Test.isRunningTest()) {
            pageReferenceChangeLanguage(new PageReference(Network.getLoginUrl(Network.getNetworkId())+'/ForgotPassword'), language, startUrl);
        }
    }
    
    //save lang param and send it to apex
    private static void pageReferenceChangeLanguage(PageReference pr, String language, String startUrl) {
        pr.getparameters().put('language', language);
        pr.getparameters().put('startURL', startUrl);
        aura.redirect(pr);
    }
}