/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 7/2017
*
*/
@isTest 
public class REIDP_DataAnonymizationTest {
    
    @testSetup static void setup() {
        List<REIDP_User_Consent__c> ucList = new List<REIDP_User_Consent__c>();
        
        System.runAs(REIDP_TestFactory.createCommunityUser(REIDP_DataAnonymizationTest.class)) {
            User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            
            REIDP_Application__c app = new REIDP_Application__c(Name = 'Test App',  
                                                                Description__c = 'This is a test app ',
                                                                Can_User_Request_Access__c = true,
                                                                Is_Active__c = true,
                                                                Is_Restricted__c = true,
                                                                Community__c = 'Castrol',
                                                                Permission_Set__c = 'DummyId',
                                                                Connected_App__c = 'DummyId',
                                                                Approver__c = UserInfo.getUserId(),
                                                                Short_Name__c = 'Name');
            insert app; 
            
            ucList.add(new REIDP_User_Consent__c(Type__c = 'General Marketing',
                                                 Version__c = '11',
                                                 User__c = UserInfo.getUserId(), 
                                                 Application__c = app.Id,
                                                 Contact__c = u.ContactId));
            
            ucList.add(new REIDP_User_Consent__c(Type__c = 'Personal Marketing',
                                                 Version__c = '11',
                                                 User__c = UserInfo.getUserId(), 
                                                 Application__c = app.Id,
                                                 Contact__c = u.ContactId));
            insert ucList;
            
            
            REIDP_Application_Access_Request__c appRequest = new REIDP_Application_Access_Request__c(Application__c = app.Id, 
                                                                                                     Status__c = 'New',
                                                                                                     User__c = UserInfo.getUserId(),
                                                                                                     Contact__c = u.ContactId);
            insert appRequest;
        }
    }
    
    @isTest
    static void testDataAnonymization() {
        
        Id accId = [SELECT Id, User__r.Contact.AccountId 
                    FROM REIDP_Application_Access_Request__c LIMIT 1].User__r.Contact.AccountId;
        
        Test.startTest();
        REIDP_DataAnonymization.DeleteAndAnonymizeCommunityUser(accId);
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM REIDP_Application_Access_Request__c].size());
        System.assertEquals(0, [SELECT Id FROM REIDP_User_Consent__c].size());
    }
}