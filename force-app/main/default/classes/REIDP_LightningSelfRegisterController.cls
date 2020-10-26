/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 */
 
global without sharing class REIDP_LightningSelfRegisterController {

    public REIDP_LightningSelfRegisterController() {

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
    public static String selfRegister(String firstname ,String lastname, String email, String language, String password, String confirmPassword, String accountId, String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.IDPLastNameRequired;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.IDPEmailRequired;
            } else {
                List<User> existingUsers = [SELECT Email FROM User WHERE Email=:email and IsActive = TRUE];
                if (existingUsers != null && !existingUsers.isEmpty()){
                    throw new DuplicateException(Label.BPDuplicateEmail);
                }
            }
            
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            
            u.FirstName = (firstname != null && firstname.length() > 0) ? firstname.capitalize() : '';
            u.LastName = lastName.capitalize();
            u.REIDP_T_C_Accepted__c = DateTime.now();
            u.REIDP_Privacy_Accepted__c = DateTime.now();
            u.LanguageLocaleKey = language;
                     
            if (extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);        
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
            
            u.put('CommunityNickname', REIDP_UserServices.generateCommunityNickName(firstname, lastname));
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword))
                    return Label.IDPPasswordNotMatch;
                validatePassword(u, password, confirmPassword);
            }
            else
                password = null;
            
            // lastName is a required field on user, but if it isn't specified, we'll default it to the username
            String userId = Site.createPortalUser(u, accountId, password);

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
            return ex.getMessage();            
        }
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
    
    public class DuplicateException extends Exception {}
}