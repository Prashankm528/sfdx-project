/**
 * @author Ksenia Potapovich
 * @company Bluewolf, an IBM Company
 * @date 11/2017
 *
 */
global without sharing class CAIDP_LightningProfileController {

    public static Map<String, String> countriesMap {
        get {
            if (countriesMap == null) {
                countriesMap = new Map<String, String>();
                Schema.DescribeFieldResult userCountryPicklist = SObjectType.User.fields.CAIDP_Country__c;
                if (userCountryPicklist != null) {
                    for(PicklistEntry entry : userCountryPicklist.getPicklistValues()) {
                        countriesMap.put(entry.getLabel(), entry.getValue());
                    }
                }
            }
            return countriesMap;
        }
        set;
    }

    @AuraEnabled
    public static void saveUser(User user, String country) {

        user.CAIDP_Country__c = countriesMap.get(country);
        user.Country = country;
        update user;
        //update contact, account
    }

    @AuraEnabled
    public static User getUser() {
        
        return [
            SELECT Name, Username, Email, Phone, CAIDP_Country__c, LastName, FirstName,
                CompanyName, Department, Address, CAIDP_Business_Name__c, 
                State, City, Country, AboutMe, MobilePhone, Street, PostalCode
            FROM User 
            WHERE Id= :UserInfo.getUserId()
        ];
    }

    @AuraEnabled
    public static List<String> getCountriesPicklist() {

        return new List<String>(countriesMap.keySet());  
    }
}