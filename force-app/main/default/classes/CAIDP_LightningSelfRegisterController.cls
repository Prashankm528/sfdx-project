/**
* @author Ksenia Potapovich
* @company Bluewolf, an IBM Company
* @date 11/2017
*/

global without sharing class CAIDP_LightningSelfRegisterController {
    
    public static String COMMUNITY_NAME = 'Castrol';
    
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
        private set;
    }
    
    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @AuraEnabled
    public static List<String> getCountriesPicklist() {
        
        return new List<String>(countriesMap.keySet());   
    }
    
    @AuraEnabled
    public static String selfRegister(String firstname, String lastname, String email, String country, String language, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            } else {
                List<User> existingUsers = [SELECT Email FROM User WHERE Email=:email];
                if (existingUsers != null && !existingUsers.isEmpty()){
                    throw new DuplicateException(Label.CastrolDuplicateEmail);
                }
            }
            if (country == null || String.isEmpty(country)) {
                return Label.CastrolCountryRequired;
            }

            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(REIDP_Constants.PERSON_ACCOUNT_RECORD_TYPE_NAME).getRecordTypeId();
            List<Account> duplicateAccounts = [
                SELECT CAIDP_Connected_Apps__pc
                FROM Account
                WHERE PersonEmail = :email
                    AND RecordTypeId = :recordTypeId
            ];
            List<String> connectedApps = new List<String>();
            if (!duplicateAccounts.isEmpty() && String.isNotEmpty(duplicateAccounts[0].CAIDP_Connected_Apps__pc)) {
                connectedApps = duplicateAccounts[0].CAIDP_Connected_Apps__pc.split(';');
            }
            delete duplicateAccounts;
            
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            
            u.FirstName = (firstname != null && firstname.length() > 0) ? firstname.capitalize() : '';
            u.LastName = lastName.capitalize();
            u.CAIDP_Country__c = countriesMap.get(country);
            u.Country = country;
            u.LanguageLocaleKey = language;
            u.CAIDP_Language__c = language;
            
            //String networkId = Network.getNetworkId();
            
            u.put('CommunityNickname', REIDP_UserServices.generateCommunityNickName(firstname, lastname));
                     
            if (extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);        
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword))
                    return Label.site.passwords_dont_match;
                validatePassword(u, password, confirmPassword);
            }
            else
                password = null;
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, accountId, password);

            List<PermissionSetAssignment> pSetAssignment = new List<PermissionSetAssignment>();
            for(REIDP_Connected_App__mdt app : [
                SELECT Permission_Set_Id__c
                FROM REIDP_Connected_App__mdt
                WHERE Label IN :connectedApps
                    AND Community_Name__c = :COMMUNITY_NAME
            ]) {

               pSetAssignment.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = app.Permission_Set_Id__c));
            }
          
            if(pSetAssignment.size() > 0) {
                insertPermissionSetAssignments(JSON.serialize(pSetAssignment));
            }

            // create a fake userId for test.
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';           
            }
            if (userId != null) { 
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                    if(!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                }
                else {
                    ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                    if(!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                   }
                }
            }
            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            if (ex.getMessage() == 'Invalid email address') {
                return Label.CastrolInvalidEmail;
            }
            return ex.getMessage();            
        }
    }
    
    // self registration with mobile phone number
    @AuraEnabled
    public static String selfRegisterPhone(String firstname ,String lastname, String phoneNumber, String countryCode, String country, String language, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        if (phoneNumber == null || String.isEmpty(phoneNumber)) {
            return Label.IDPPhoneNumberRequired;
        }
        if (countryCode == null || String.isEmpty(countryCode)) {
            return Label.IDPPhoneCountryCodeRequired;
        }
        return selfRegister(firstname, 
                            lastname, 
                            REIDP_UserServices.formatMobileUsername(countryCode, phoneNumber), 
                            country, 
                            language, 
                            password,
                            confirmPassword,
                            accountId,
                            regConfirmUrl, 
                            extraFields, 
                            startUrl,
                            includePassword);
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,String>> extraFields = new List<Map<String,String>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
            if (fieldSet != null) {
                for (Schema.FieldSetMember f : fieldSet.getFields()) {
                    Map<String, String> fieldDetail = new Map<String, String>();
                    fieldDetail.put('dbRequired', String.valueOf(f.getDBRequired()));
                    fieldDetail.put('fieldPath', f.getFieldPath());
                    fieldDetail.put('label', f.getLabel());
                    fieldDetail.put('required', String.valueOf(f.getRequired()));
                    fieldDetail.put('type', String.valueOf(f.getType()));
                    fieldDetail.put('value', '');   // client will populate
                    extraFields.add(fieldDetail);
                }}}
        return extraFields;
    }
    
    @future
    public static void insertPermissionSetAssignments(String assignmentsToInsert) {
        List<PermissionSetAssignment> assignments = (List<PermissionSetAssignment>)JSON.deserialize(
            assignmentsToInsert, List<PermissionSetAssignment>.class
        );
        insert assignments;
    }
    
    public class DuplicateException extends Exception {}
}