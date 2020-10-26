/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 08/2018
 *
 * TestFactory class that implements data creation methods for various test Classes
 */
@isTest
public class REIDP_TestFactory {
    public static String DEFAULT_COMMUNITY = 'BP';
    private static String adminProfileId {
        get {
         	if(adminProfileId == null)
                adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
            return adminProfileId;
        }
        set;
    }
    private static User userWithRole;
    
    private static string idpProfileId {
        get {
         	if(idpProfileId == null)
                idpProfileId = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1].Id;
            return idpProfileId;
        }
        set;
    }
    
    public static String generateUniqueUserEmail(System.Type classType) {
        return (classType.getName() + System.now().getTime() + '@test' + UserInfo.getOrganizationId() + '.org').toLowerCase();
    }
    
    public static String generateUniqueUserPhoneNumberEmail() {
        return (System.now().getTime() + '.' + System.now().getTime() + '@idp.bp.com');
    }
    
    public static User createUserWithRole() {
        //Create User with role only once and reuse it in same transaction
        if(userWithRole != null)
            return userWithRole;
        
        //Isolated to avoid Mixed DML Exceptions
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole r = new UserRole(name = 'TEST ROLE');
            Database.insert(r);
            
            String userEmail = generateUniqueUserEmail(REIDP_TestFactory.class);
            
            userWithRole = new User(alias = 'hasrole', email=userEmail, userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = adminProfileId, 
                                    timezonesidkey='America/Los_Angeles', username=userEmail);
            
            insert userWithRole;
        }
        
        return userWithRole;
    }
    
    private static User createCommunityUser(System.Type classType, Boolean isPhoneNumberUser, Map<String, Object> params) {
        String userEmail = isPhoneNumberUser ? generateUniqueUserPhoneNumberEmail() : generateUniqueUserEmail(classType);
        Account a;
        
        System.runAs(createUserWithRole()){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccount', PersonEmail = userEmail);
            insert a;
        }
        
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = userEmail,
            Username = userEmail,
            Alias = 'TestCA', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = idpProfileId, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId
        );
        
        //Set additional params on User object
        if(params != null) {
            for(String key : params.keySet()) {
                u.put(key, params.get(key));
            }
        }
        
        insert u;
        
        //Isolated to avoid mixed DML
        System.runAs(new User(Id = UserInfo.getUserId())) {
            u.REIDP_Default_Community__c = DEFAULT_COMMUNITY;
            update u;
        }
        return u;
    }
    
    public static User createCommunityUser(System.Type classType) {
        return createCommunityUser(classType, false, null);
    }
    
    public static User createCommunityUser(System.Type classType, Map<String, Object> params) {
        return createCommunityUser(classType, false, params);
    }    
    
    public static User createCommunityPhoneNumberUser() {
        return createCommunityUser(REIDP_TestFactory.class, true, null);
    }
}