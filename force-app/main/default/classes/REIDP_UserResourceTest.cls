/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 6/2017
*
* This test class for self registration via the API (REIDP_UserResource)
*/
@isTest
public with sharing class REIDP_UserResourceTest {
    
    @testSetup static void setup() {
        // create Application
        REIDP_Application__c app = new REIDP_Application__c();
        app.Name = 'Test App';
        app.Permission_Set__c = 'test';
        app.Short_Name__c = 'testApp';
        app.Connected_App__c = 'testApp';
        insert app;
    }
    
    @isTest
    static void testSelfRegisterFail() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(null);
        System.assertEquals(null, ucRes.userId);
        System.assertNotEquals(null, ucRes.message);   
    }
    
    @isTest
    static void testSelfRegisterAddressInfoSuccess() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        
        
        ucReq.title = 'Mr.';
        ucReq.addressStreet = 'Test Address 1337';
        ucReq.addressCity = 'Boston';
        ucReq.addressPostalCode = '13000';
        ucReq.addressState = 'Springfield';
        ucReq.addressCountry = 'USA';
        ucReq.addressStreetLine2 = 'Test address 2';
        ucReq.birthdate = Date.newInstance(2019, 1, 1);
        
        ucReq.email = REIDP_TestFactory.generateUniqueUserEmail(REIDP_UserResourceTest.class);
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language='en_US';
        ucReq.apps =  new List<String>{'app test'};
            REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertNotEquals(null, ucRes.userId);
        User u = [SELECT Id, Title, Street, City, PostalCode, State, Country, Address_Line_2__c, Birthdate__c FROM User
                 WHERE Id=:ucRes.userId];
        System.assertEquals(ucReq.title, u.Title);
        System.assertEquals(ucReq.addressStreet, u.Street);
        System.assertEquals(ucReq.addressCity, u.City);
        System.assertEquals(ucReq.addressPostalCode, u.PostalCode);
        System.assertEquals(ucReq.addressState, u.State);
        System.assertEquals(ucReq.addressCountry, u.Country);
        System.assertEquals(ucReq.addressStreetLine2, u.Address_Line_2__c);
        System.assertEquals(ucReq.birthdate, u.Birthdate__c);
    }
    
    @isTest
    static void testSelfRegisterSuccess() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = REIDP_TestFactory.generateUniqueUserEmail(REIDP_UserResourceTest.class);
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language='en_US';
        ucReq.apps =  new List<String>{'app test'};
            REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertNotEquals(null, ucRes.userId);
    }
    
    @isTest
    static void testNoRestSelfRegisterDuplicateFail() {
        User u = REIDP_TestFactory.createCommunityUser(REIDP_UserResourceTest.class);
        String email = u.Email;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = email;
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language='en_US';
        ucReq.apps =  new List<String>{'app test'};
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertEquals(409, res.statusCode); 
    }
    
    @isTest
    static void testNoRestSelfRegisterSuccessExternalCommunityProfile() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = REIDP_TestFactory.generateUniqueUserEmail(REIDP_UserResourceTest.class);
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language = 'en_US';
        ucReq.communityPath = 'BP IDP';
        ucReq.apps =  new List<String>{'app test'};
        Test.startTest();
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        Test.stopTest();
        User userResult = [SELECT Id, ProfileId FROM User WHERE Id =: ucRes.userId];
        Profile p = [SELECT Id FROM Profile WHERE Name =: 'RE IDP External Identity BP' LIMIT 1];
        System.assertNotEquals(null, ucRes.userId);
        System.assertEquals(p.Id, userResult.ProfileId);
        
    }
    
    @isTest
    static void testNoRestSelfRegisterSuccess() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = REIDP_TestFactory.generateUniqueUserEmail(REIDP_UserResourceTest.class);
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language='en_US';
        ucReq.apps =  new List<String>{'app test'};
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertNotEquals(null, ucRes.userId);
    }
    
    @isTest
    static void testSelfRegisterSuccessWithIncorrectLanguage() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = REIDP_TestFactory.generateUniqueUserEmail(REIDP_UserResourceTest.class);
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language='fake';
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertNotEquals(null, ucRes.userId);
    }
    
    @isTest
    static void testSelfRegisterDuplicateUser() {
        User u = REIDP_TestFactory.createCommunityUser(REIDP_UserResourceTest.class);
        String email = u.Email;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = email;
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertEquals(409, res.statusCode); 
        
    }

    @isTest
    static void testSelfRegisterSuccessWithConsent() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/IdPUser';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        REIDP_UserResource.UserCreateRequest ucReq = new REIDP_UserResource.UserCreateRequest();
        
        REIDP_Application__c app = [SELECT Id, Short_Name__c FROM REIDP_Application__c LIMIT 1];
        
        ucReq.firstname = 'Test';
        ucReq.lastname = 'Test';
        ucReq.phone = '1234567890';
        ucReq.email = REIDP_TestFactory.generateUniqueUserEmail(REIDP_UserResourceTest.class);
        ucReq.generalMarketing = true;
        ucReq.personalMarketing = true;
        ucReq.language='en_US';
        ucReq.apps =  new List<String>{app.Short_Name__c};
            
        REIDP_UserConsentResource.UserConsentCreateRequest consent = new REIDP_UserConsentResource.UserConsentCreateRequest();
        
        consent.accepted = true;
        consent.appName = app.Short_Name__c;
        consent.channel = null;
        consent.consentType = 'Personal Marketing';
        
        ucReq.consents = new List<REIDP_UserConsentResource.UserConsentCreateRequest>{consent};
            
        REIDP_UserResource.UserCreateResponse ucRes = REIDP_UserResource.selfRegister(ucReq);
        System.assertNotEquals(null, ucRes.userId);
    }
    
}