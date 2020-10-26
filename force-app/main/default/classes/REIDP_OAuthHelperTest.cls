/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 09/2017
 * 
 */
@IsTest(SeeAllData = true)
public class REIDP_OAuthHelperTest {
    
    @IsTest
    static void testRevokeTokensForUser() {
        REIDP_RevokeOAuthTokenMock calloutMock = new REIDP_RevokeOAuthTokenMock();
        Test.setMock(HttpCalloutMock.class, calloutMock);
        System.runAs(createTestUser()) {
            REIDP_OAuthHelper.revokeTokensForUser(UserInfo.getUserId());
        }
    }
    
    @IsTest
    static void testRevokeToken() {
        REIDP_RevokeOAuthTokenMock calloutMock = new REIDP_RevokeOAuthTokenMock();
        Test.setMock(HttpCalloutMock.class, calloutMock);
        REIDP_OAuthHelper.revokeToken('testToken1');
    }
    
    @IsTest
    static void testRevokeTokens() {
        REIDP_RevokeOAuthTokenMock calloutMock = new REIDP_RevokeOAuthTokenMock();
        Test.setMock(HttpCalloutMock.class, calloutMock);
        REIDP_OAuthHelper.revokeTokens(new List<String>{'testToken1', 'testToken2'});
    }
    
    
    @IsTest
    static void testSendRevokeRequest() {
        REIDP_RevokeOAuthTokenMock calloutMock = new REIDP_RevokeOAuthTokenMock();
        Test.setMock(HttpCalloutMock.class, calloutMock);
        
        List<String> mockTokens = new List<String>{'testToken1', 'testToken2'};
            
        Test.startTest();
        List<HttpResponse> responses = REIDP_OAuthHelper.sendRevokeRequest(mockTokens);
        Test.stopTest();
        
        System.assertEquals(2, calloutMock.tokens.size());
        System.assert(calloutMock.tokens.contains('token=testToken1'));
        System.assert(calloutMock.tokens.contains('token=testToken2'));
        System.assertEquals(2, responses.size());
        System.assertEquals(200, responses[0].getStatusCode());
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