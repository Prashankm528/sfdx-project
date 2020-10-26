/**
*
* @author Nazim Aliyev & Anna Mokhubova 
* @company Bluewolf, an IBM Company
* @date 03/06/2019
*
**/

@isTest
public class REIDP_SocialLoginHandlerTest {
    
    @IsTest 
    public static void testCanCreateUserSuccess() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        Auth.UserData data = createUser('test@example.com','TestName','TestLastName');
        
        System.Assert(handler.canCreateUser(data), 'Handler should be able to create this user');
    }
    
    @IsTest 
    public static void testCanCreateUserFail() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        Auth.UserData data = createUser(null, 'TestName','TestLastName');
        
        System.Assert(!handler.canCreateUser(data), 'Handler should not be able to create user with missing email');
    }
    /*
    @IsTest
    public static void testCreateInternalUser() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        Auth.UserData data = createUser('test@example.com', 'TestName','TestLastName');
        
        Test.startTest();
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        
        validate(theUser,data);
        
    }*/
    
    @IsTest
    public static void testCreateInternalUserNegative() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        Auth.UserData data = createUser(null, 'TestName', 'TestLastName');
        
        Test.startTest();
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        
        System.Assert(theUser == null, 'User should be null for negative case');
        
    }
    /*
    @IsTest
    public static void testUpdateUser() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        
        Auth.UserData data = createUser('test@example.com','TestName','TestLastName');
        User theUser = handler.createUser(null, data);
        
        Test.startTest();
        validate(theUser, data);
        System.runAs(theUser) {
            data.firstName = 'Tom';
            handler.updateUser(theUser.id, null, data);
        }
        
        Test.stopTest();
        User theUpdatedUser = [SELECT Id, FirstName, Email, LastName 
                               FROM User 
                               WHERE Id = :theUser.id];
        validate(theUpdatedUser, data);
    }
    */
    @IsTest
    public static void testCommunityFail() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        
        Auth.UserData data = createUser('test@example.com','TestName','TestLastName');
        data.attributeMap.remove('sfdc_networkid');
        
        Test.startTest();
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        // Additional validation, because community is null
        System.assertEquals(null, theUser);
        
    }
    /*
    @IsTest
    public static void testCreateCommunityUser() {
        REIDP_SocialLoginHandler handler = new REIDP_SocialLoginHandler();
        Auth.UserData data = createUser('test@example.com', 'TestName', 'TestLastName');
        
        Test.startTest();
        String theCommunityId = '00000001';
        data.attributeMap.put('sfdc_networkid', theCommunityId);
        User theUser = handler.createUser(null, data);
        Test.stopTest();
        
        validate(theUser, data);
        // Additional validations for Community User
        System.Assert(theUser.ContactId != null, 'Contact must be set for user');
        
    }*/
    
    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser != null, 'User must not be null');
        System.AssertEquals(theUser.email, data.email, 'Email address must be the same');
        System.AssertEquals(theUser.FirstName, data.FirstName, 'First name must match');
        System.AssertEquals(theUser.LastName, data.LastName, 'Last name must match');
    }
    
    
    private static Auth.UserData createUser(String email, String lastName, String firstName) {
        Map<String, String> attributeMap = new Map<String,String>();
        String identifier = lastName + System.currentTimeMillis();
        String locale = 'en_US';
        attributeMap.put('sfdc_networkid', '00000001');
        return new Auth.UserData( identifier,
                                 firstName,
                                 lastName,
                                 '', // fullname
                                 email,
                                 '', // link
                                 '', // userName
                                 locale,
                                 '', // provider
                                 '', // siteLoginUrl
                                 attributeMap);       
    }
}