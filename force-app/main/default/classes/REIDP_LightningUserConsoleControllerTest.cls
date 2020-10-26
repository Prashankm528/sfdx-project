/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 */
@isTest 
public class REIDP_LightningUserConsoleControllerTest {
	
    @isTest
    static void testGetUserInformation() {
        System.runAs(createTestUser()) {
            Test.startTest();
            String orgId = UserInfo.getOrganizationId();
            User u = REIDP_LightningUserConsoleController.getUserInformation();
            System.assertEquals('Test Test', u.Name);
            System.assertEquals(('GetUserInformationTest@test' + orgId + '.org').toLowerCase(), u.Email.toLowerCase());
            System.assertEquals('1234567890', u.Phone);
            Test.stopTest();
        }
    }
    
    public static User createTestUser()
    {
        String orgId = UserInfo.getOrganizationId();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User tuser = new User(firstname = 'Test',
                              lastName = 'Test',
                              email = 'GetUserInformationTest@test' + orgId + '.org',
                              Username = 'GetUserInformationTest@test' + orgId + '.org',
                              Alias = 'guiTest',
                              Phone = '1234567890',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'ISO-8859-1',
                              ProfileId = pf.Id,
                              UserRoleId = ur.Id);
        return tuser;
    }
}