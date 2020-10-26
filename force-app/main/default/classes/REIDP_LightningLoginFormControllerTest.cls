/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 */
@IsTest(SeeAllData = true)
public with sharing class REIDP_LightningLoginFormControllerTest {

    public static final String PASSWORD_STATUS_CORRECT = 'Success';
    
    @IsTest
    static void testLoginWithInvalidCredentials() {
        System.assertEquals(Label.IDPLoginError, REIDP_LightningLoginFormController.login('testUser', 'fakepwd', null));
    }
    
    @IsTest
    static void REIDP_LightningLoginFormControllerInstantiation() {
        REIDP_LightningLoginFormController controller = new REIDP_LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, REIDP_LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, REIDP_LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = REIDP_LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    
    @isTest
    static void testPasswordLockoutEmail() {
        Test.startTest();
        User thisUser = [select Id, Email from User where Id = :UserInfo.getUserId()]; 
        User communityUser;
        try {
           communityUser = createCommunityUser('revokeusertoken@bp.com.reidpserviceuser');
        } catch (Exception ex) {
            communityUser = thisUser;
        }
        
        System.runAs(thisUser) { 
            List<Messaging.SendEmailResult> results = REIDP_LightningLoginFormController.sendEmail(communityUser.Id, communityUser.Email);
            System.assertEquals(2, results.size());
            System.assert(results[0].isSuccess());
            System.assert(results[1].isSuccess());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testLoginWithInvalidPassword() {
        Test.startTest();
        String communityUserEmail = 'testEmail@BPuser.com';
        String communityUserPassword = 'passPASS1234!@';
        User communityUser = createCommunityUser(communityUserEmail);
        String communityUserId = communityUser.Id;
        System.setPassword(communityUserId, communityUserPassword);
        
        List<LoginHistoryWrapper> lhws = new List<LoginHistoryWrapper>();
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-60), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-155), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-220), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-240), PASSWORD_STATUS_CORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-450), PASSWORD_STATUS_CORRECT));
        
        List<LoginHistory> lhlist = (List<LoginHistory>)JSON.deserialize(JSON.serialize(lhws), List<LoginHistory>.class);
        
        List<UserLoginWrapper> ulw = new List<UserLoginWrapper>{new UserLoginWrapper(communityUserId, false)};
        
        List<UserLogin> loginInfo = (List<UserLogin>)JSON.deserialize(JSON.serialize(ulw), List<UserLogin>.class);

        String response = REIDP_LightningLoginFormController.getLoginError(communityUser, loginInfo, lhlist, getPasswordPolicy());
        String amntAvailable = String.valueOf(Integer.valueOf(getPasswordPolicy().Maximum_Invalid_Login_Attempts__c - 3));
        System.assertEquals(String.format(Label.IDPInvalidPassword, new String[]{amntAvailable}), response);  
        Test.stopTest();
    }
    
    @IsTest
    static void testGetIsUsernamePasswordEnabled() {
        System.assertEquals(true, REIDP_LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testLoginPhone() {
        System.assertEquals(Label.IDPPhoneCountryCodeRequired, REIDP_LightningLoginFormController.loginPhone(null, '123456789', 'testpass', 'testURL'));
        System.assertEquals(Label.IDPPhoneNumberRequired, REIDP_LightningLoginFormController.loginPhone('123456789', null, 'testpass', 'testURL'));
    }
    
    @IsTest
    static void testLoginWithPasswordLockout() {
        Test.startTest();
        String communityUserEmail = 'testEmail@BPuser.com';
        String communityUserPassword = 'passPASS1234!@';
        User communityUser = createCommunityUser(communityUserEmail);
        String communityUserId = communityUser.Id;
        System.setPassword(communityUserId, communityUserPassword);
        
        List<LoginHistoryWrapper> lhws = new List<LoginHistoryWrapper>();
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-60), REIDP_LightningLoginFormController.PASSWORD_STATUS_LOCKOUT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-155), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-220), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-240), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        lhws.add(new LoginHistoryWrapper(communityUserId, Datetime.now().addSeconds(-450), REIDP_LightningLoginFormController.PASSWORD_STATUS_INCORRECT));
        
        List<LoginHistory> lhlist = (List<LoginHistory>)JSON.deserialize(JSON.serialize(lhws), List<LoginHistory>.class);

        List<UserLoginWrapper> ulw = new List<UserLoginWrapper>{new UserLoginWrapper(communityUserId, true)};
        
        List<UserLogin> loginInfo = (List<UserLogin>)JSON.deserialize(JSON.serialize(ulw), List<UserLogin>.class);

        String response = REIDP_LightningLoginFormController.getLoginError(communityUser, loginInfo, lhlist, getPasswordPolicy());
        String unlockTime = String.valueOf(Integer.valueOf(getPasswordPolicy().Lockout_Effective_Period__c));
        System.assertEquals(String.format(Label.IDPPasswordLockout, new String[]{unlockTime,unlockTime}), response); 
        Test.stopTest();
    }
    
    @IsTest
    static void testLogin() {
        Test.startTest();
        String communityUserEmail = 'testEmail@BPuser.com';
        String communityUserPassword = 'passPASS1234!@';
        User communityUser = createCommunityUser(communityUserEmail);
        String communityUserId = communityUser.Id;
        System.setPassword(communityUserId, communityUserPassword);
        
        String response = REIDP_LightningLoginFormController.login(communityUserEmail, communityUserPassword, '/');        
        System.assertEquals(Label.IDPLoginError, response);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetLoginOption() {
        Test.startTest();
        REIDP_LightningLoginFormController.LoginOptions lo = REIDP_LightningLoginFormController.getLoginOption();        
        System.assertEquals(null, lo);
        Test.stopTest();
    }
    
    public Class LoginHistoryWrapper {
        public String Status;
        public Datetime LoginTime;
        public String UserId;
        
        public LoginHistoryWrapper(String userId, Datetime loginTime, String status) {
            this.Status = status;
            this.LoginTime = loginTime;
            this.UserId = userId;
        }
    }
    
    public Class UserLoginWrapper {
        
        public String UserId;
        public Boolean IsPasswordLocked;
        
        public UserLoginWrapper(String userId, Boolean isPasswordLocked) {
            this.UserId = userId;
            this.IsPasswordLocked = isPasswordLocked;
        }
    }
    
    public static User createCommunityUser(String email) {
        UserRole r = new UserRole(name = 'TEST ROLE');
        Database.insert(r);
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                     emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                     localesidkey='en_US', profileid = pf.Id, 
                                     timezonesidkey='America/Los_Angeles', username='userwithrole@testclass_bp'+System.currentTimeMillis()+'.com');
        Account a;
        System.runAs(userWithRole){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RE IDP Person Account').getRecordTypeId();
            a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccount', PersonEmail = email);
            insert a;
        }
        Account acc = [Select PersonContactId From Account Where Id = :a.Id];
        Profile p = [SELECT Id FROM Profile WHERE Name = :REIDP_Constants.GENERAL_IDP_PROFILE_NAME LIMIT 1];
        User u = new User(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = email,
            Username = email,
            Alias = 'TestBP', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US',
            ContactId = acc.PersonContactId);
        insert u;
        return u;
    }
    
    private static REIDP_Password_Policy__mdt getPasswordPolicy() {
        return [SELECT Lockout_Effective_Period__c, Maximum_Invalid_Login_Attempts__c 
                FROM REIDP_Password_Policy__mdt 
                WHERE DeveloperName =:REIDP_LightningLoginFormController.PASSWORD_POLICY];
    }
    
}