/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 1/2019
 *
 * Test class for REIDP_UserConsentResource
 * 
 */
@isTest
public class REIDP_UserConsentResourceTest {
    
    @testSetup static void setup() {
        REIDP_Application__c app = new REIDP_Application__c();
        app.Name = 'Test App';
        app.Permission_Set__c = 'test';
        app.Short_Name__c = 'testApp';
        app.Connected_App__c = 'testApp';
        insert app;
    }

    // Test For HttpGet
    @isTest
    static void testGetUserConsent_Success() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserConsentResource.UserConsentResponse ucRes = REIDP_UserConsentResource.getUserConsent();
        System.assertNotEquals(null, ucRes.userConsents);
        System.assertEquals(true, ucRes.success);
        System.assertEquals(null, ucRes.message);  
    }

    // Test For HttpPost
    @isTest
    static void testUpdateUserConsent_Fail() {
        Boolean isFailed = false;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
        REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
        ucReqList.add(ucReq);
        REIDP_UserConsentResource.UserConsentResponse ucRes;
        try {
            ucRes = REIDP_UserConsentResource.updateUserConsent(ucReqList);
        } catch (JSONException jsonE) {
            isFailed = true;
            System.assert(isFailed);
        }
    }

    @isTest
    static void testUpdateUserConsent_Success() {
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentResourceTest.class);
        
        REIDP_Application__c app = [SELECT Id, Short_Name__c FROM REIDP_Application__c LIMIT 1];
        REIDP_User_Consent__c consent;
        
        System.runAs(testUser) {
            List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
            REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
            ucReq.appName = app.Short_Name__c;
            ucReq.accepted = true;
            ucReq.consentType = 'General Marketing';
            ucReq.version = '11';
            ucReq.channel = new List<String>{'Email', 'SMS'};
            ucReqList.add(ucReq);
            REIDP_UserConsentResource.UserConsentResponse ucRes = REIDP_UserConsentResource.addUserConsent(ucReqList);
            consent = ucRes.userConsents.get(0);
        }
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(testUser) {
            List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
            REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
            ucReq.accepted = false;
            ucReq.consentId = consent.Id;
            ucReq.consentType = 'General Marketing';
            ucReqList.add(ucReq);
            REIDP_UserConsentResource.UserConsentResponse ucRes = REIDP_UserConsentResource.updateUserConsent(ucReqList);
            System.assertEquals(true, ucRes.success);
            System.assertEquals(null, ucRes.message);   
        }
    } 
    
    @isTest 
    static void testAddUserConsent_Fail() {
        Boolean isFailed = false;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentResourceTest.class);
        List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
        REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
        ucReqList.add(ucReq);
        REIDP_UserConsentResource.UserConsentResponse ucRes;
        try {
            ucRes = REIDP_UserConsentResource.addUserConsent(ucReqList);
        } catch (JSONException jsonE) {
            isFailed = true;
            System.assert(isFailed);
        }
        
    }

    @isTest 
    static void testAddUserConsent_Success() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentResourceTest.class);
        
        REIDP_Application__c app = [SELECT Id, Short_Name__c FROM REIDP_Application__c LIMIT 1];
        
        System.runAs(testUser) {
            List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
            REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
            ucReq.appName = app.Short_Name__c;
            ucReq.accepted = true;
            ucReq.consentType = 'General Marketing';
            ucReq.version = '11';
            ucReq.channel = new List<String>{'Email', 'SMS'};
            ucReqList.add(ucReq);
            REIDP_UserConsentResource.UserConsentResponse ucRes = REIDP_UserConsentResource.addUserConsent(ucReqList);
            System.assertNotEquals(0, ucRes.userConsents.size());
            System.assertEquals(true, ucRes.success);
            System.assertEquals(null, ucRes.message);
        }
    } 

    @isTest 
    static void testAddUserConsent_ExceptionFail() {
        Boolean isFailed = false;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;

        REIDP_Application__c app = [SELECT Id, Short_Name__c FROM REIDP_Application__c LIMIT 1];
        List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
        REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
        ucReq.appName = app.Short_Name__c;
        ucReq.accepted = true;
        ucReq.consentType = 'General Marketing';
        ucReq.version = '11';
        ucReq.channel = new List<String>{'Email', 'SMS'};
            ucReqList.add(ucReq);
        REIDP_UserConsentResource.UserConsentResponse ucRes = REIDP_UserConsentResource.addUserConsent(ucReqList);
        try {
            ucRes = REIDP_UserConsentResource.addUserConsent(ucReqList);
        } catch (Exception e) {
            isFailed = true;
            System.assert(isFailed);
        }
    }

    @isTest
    static void testUpdateUserConsent_ExceptionFail() {
        Boolean isFailed = false;
        
        User testUser = REIDP_TestFactory.createCommunityUser(REIDP_UserConsentResourceTest.class);
        
        REIDP_Application__c app = [SELECT Id, Short_Name__c FROM REIDP_Application__c LIMIT 1];
        REIDP_User_Consent__c consent;
        
        System.runAs(testUser) {
            List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
            REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
            ucReq.appName = app.Short_Name__c;
            ucReq.accepted = true;
            ucReq.consentType = 'General Marketing';
            ucReq.version = '11';
            ucReq.channel = new List<String>{'Email', 'SMS'};
            ucReqList.add(ucReq);
            REIDP_UserConsentResource.UserConsentResponse ucRes = REIDP_UserConsentResource.addUserConsent(ucReqList);
            consent = ucRes.userConsents.get(0);
        }
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserConsent';
        req.httpMethod = 'PUT';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        List<REIDP_UserConsentResource.UserConsentCreateRequest> ucReqList = new List<REIDP_UserConsentResource.UserConsentCreateRequest>();
        REIDP_UserConsentResource.UserConsentCreateRequest ucReq = new REIDP_UserConsentResource.UserConsentCreateRequest();
        ucReq.accepted = false;
        ucReq.consentId = consent.Id;
        ucReq.consentType = 'General Marketing';
        ucReqList.add(ucReq);
        REIDP_UserConsentResource.UserConsentResponse ucRes; 

        try {
            ucRes = REIDP_UserConsentResource.updateUserConsent(ucReqList);
        } catch (Exception e) {
            isFailed = true;
            System.assert(isFailed);
        }
    }
}