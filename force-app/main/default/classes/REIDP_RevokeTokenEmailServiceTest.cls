/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 11/2017
* 
*/
@IsTest
public class REIDP_RevokeTokenEmailServiceTest {
    
    @IsTest
    static void testEmailService() {
        
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        String uid;
        System.runAs(createTestUser()) {
            uid = UserInfo.getUserId();
        }

        // setup the data for the email
        email.subject = 'Test Email';
        email.fromname = '';
        env.fromAddress = 'accounts_team@bp.com';
        email.plainTextBody = uid;
                
        // call the email service class and test it with the data in the testMethod
        REIDP_RevokeTokenEmailService emailProcess = new REIDP_RevokeTokenEmailService();
        emailProcess.handleInboundEmail(email, env);
    }
    
    public static User createTestUser()
    {
        String orgId = UserInfo.getOrganizationId();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User tuser = new User(firstname = 'Test',
                              lastName = 'Test',
                              email = 'REIDP_OAuthHelper@test' + orgId + '.org',
                              Username = 'REIDP_OAuthHelper@test' + orgId + '.org',
                              Alias = 'oahTest',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'ISO-8859-1',
                              ProfileId = pf.Id,
                              UserRoleId = ur.Id);
        return tuser;
    }
}