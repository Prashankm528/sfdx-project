/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 09/2018
*
**/

public class REIDP_PhoneNumberInputController {
    
    public class CountryCode {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Boolean selected;
        
        public CountryCode(String value, String label, Boolean selected) {
            this.value = value;
            this.label = label;
            this.selected = selected;
        }
    }
    
    @AuraEnabled
    public static List<CountryCode> getCountryCallingCodes() {
        List<CountryCode> country = new List<CountryCode>();
        
        for(REIDP_Country_Calling_Code__mdt ccd : [SELECT MasterLabel, Calling_Code__c, Country_Code__c, Order__c
                                                   FROM REIDP_Country_Calling_Code__mdt
                                                   WHERE IsActive__c = TRUE
                                                   ORDER BY Order__c ASC NULLS LAST, Calling_Code__c ASC
                                                   LIMIT 1000]) {
            String cCode = String.valueOf(Integer.valueOf(ccd.Calling_Code__c));
            country.add(new CountryCode(cCode + '_' + ccd.Country_Code__c,
                                        '+' + cCode, 
                                        country.size() == 0 ? true : false));
        }
        
        return country;
    }
    
    @AuraEnabled
    public static CountryCode getDefaultCountryCode() {
        String expId;
        
        //Use test expirience settings during Unit Test execution
        if(Test.isRunningTest())
            expId = 'test';
        else
            expId = Site.getExperienceId();
        
        // gets default country phone code based on app exp settings
        try {
            REIDP_Community_Experience_Settings__mdt communityExpSettings = [SELECT Id, 
                                                                             Experience__c, 
                                                                             Country_Calling_Code__c
                                                                             FROM REIDP_Community_Experience_Settings__mdt 
                                                                             WHERE Experience__c = :expId
                                                                             LIMIT 1];
            
            REIDP_Country_Calling_Code__mdt code = [SELECT Id, 
                                                    MasterLabel,
                                                    Calling_Code__c,
                                                    Country_Code__c,
                                                    Order__c
                                                    FROM REIDP_Country_Calling_Code__mdt
                                                    WHERE IsActive__c = TRUE
                                                    AND Id =: communityExpSettings.Country_Calling_Code__c
                                                    LIMIT 1];
            
            return new CountryCode(code.Calling_Code__c.intValue() + '_' + code.Country_Code__c,
                                   '+' + code.Calling_Code__c.intValue(), 
                                   true);
        } catch (Exception e) {
            return null;
        }
    }
}