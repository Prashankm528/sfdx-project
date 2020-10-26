/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 6/2017
*
* A Test class for REIDP_EmailVerification Process
*/
@isTest
public class REIDP_EmailVerificationTest {
    
    public static User testUser {
        public get {
            if(testUser == null)
                testUser = createTestUser();
            return testUser;
        }
    }
    
	@isTest
    static void testBeforeAndAfterTriggers() {
        Test.startTest();
        System.runAs(testUser) {
            testUser.Email = 'emailChangeTest.new@test' + UserInfo.getOrganizationId() + '.org';
            update testUser;           
        }
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_EmailVerificationSendVerificationCode() {
        Test.startTest();
        System.runAs(testUser) {
            testUser.REIDP_New_Email__c = 'newEmailTestBP@test' + UserInfo.getOrganizationId() + '.com';
            update testUser;
			REIDP_EmailVerification.usersWithEmailChange = new Map<String, String>();
            REIDP_EmailVerification.usersWithEmailChange.put(testUser.Id, testUser.REIDP_New_Email__c);
            REIDP_EmailVerification.sendVerificationCode(REIDP_EmailVerification.usersWithEmailChange);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_EmailVerificationGenerateRandomString() {
        Test.startTest();
		System.assertEquals(REIDP_EmailVerification.generateRandomString(10).length(), 10);
        Test.stopTest();
    }
    
    @isTest
    static void testREIDP_EmailVerificationControllerCheckCodeSuccess() {
        Test.startTest();
        System.runAs(testUser) {
            testUser.REIDP_New_Email__c = 'newEmailTestBP@test' + UserInfo.getOrganizationId() + '.com';
            testUser.REIDP_New_Email_Verification_Code__c = 'testCode';
            update testUser;
            PageReference pageRef = Page.REIDP_EmailVerification;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('uid', UserInfo.getUserId());
            ApexPages.currentPage().getParameters().put('email', testUser.REIDP_New_Email__c);
            ApexPages.currentPage().getParameters().put('code', testUser.REIDP_New_Email_Verification_Code__c);
            REIDP_EmailVerificationController evController = new REIDP_EmailVerificationController();
			System.assertEquals(null, evController.checkCode());
        }
        Test.stopTest();
    }


    @isTest
    static void testREIDP_EmailVerificationControllerCheckCodeError() {
        Test.startTest();
        System.runAs(testUser) {
            testUser.REIDP_New_Email__c = 'newEmailTestBP@test' + UserInfo.getOrganizationId() + '.com';
            testUser.REIDP_New_Email_Verification_Code__c = 'testCode';
            update testUser;
            PageReference pageRef = Page.REIDP_EmailVerification;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('uid', 'invalidId');
            ApexPages.currentPage().getParameters().put('email', testUser.REIDP_New_Email__c);
            ApexPages.currentPage().getParameters().put('code', testUser.REIDP_New_Email_Verification_Code__c);
            REIDP_EmailVerificationController evController = new REIDP_EmailVerificationController();
			System.assertEquals('/?email=newEmailTestBP%40test' + UserInfo.getOrganizationId() + '.com&retUrl=%2Fapex%2Femailverification%3Fcode%3DtestCode&uid=invalidId', 
                                evController.checkCode().getUrl());
        }
        Test.stopTest();
    }
    
    public static User createTestUser()
    {
        String orgId = UserInfo.getOrganizationId();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       	
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User tuser = new User(firstname = 'Test',
                              lastName = 'Test',
                              email = 'newEmailTest@test' + orgId + '.org',
                              Username = 'newEmailTest@test' + orgId + '.org',
                              Alias = 'neTest',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'ISO-8859-1',
                              ProfileId = pf.Id,
                              UserRoleId = ur.Id);
        return tuser;
    }
}