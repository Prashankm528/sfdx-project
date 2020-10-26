/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 12/06/2018
*
**/

@isTest
public class REIDP_ApplicationAccessServiceTest {
    
    @testSetup static void setup() {
		//Permission Set creation is done in future method to avoid MIXED DML
        //To force synchronious permission set creation startTest & stopTest were used.
        Test.startTest();
        createPermissionSet();
        Test.stopTest();
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name LIKE 'REIDP_ApplicationAccessServiceTest%' LIMIT 1];
        
        insert new REIDP_Application__c(Name = 'Test App ',  
                                        Description__c = 'This is a test app ',
                                        Can_User_Request_Access__c = true,
                                        Community__c = 'Castrol',
                                        Is_Active__c = true,
                                        Is_Restricted__c = true,
                                        Permission_Set__c = ps.Id,
                                        Connected_App__c = 'DummyId',
                                        Short_Name__c = 'Short Name',
                                        Approver__c = UserInfo.getUserId());
        
        REIDP_AppAccessRequestController.Application app = REIDP_AppAccessRequestController.getListOfRestrictedApps().get(0);
        REIDP_AppAccessRequestController.createNewAccessRequest(app.Id);
    }
    
    @isTest
    public static void processApprovedRequests() {
        List<REIDP_Application_Access_Request__c> newAccessRequests =  [SELECT Id, Application__r.Permission_Set__c FROM REIDP_Application_Access_Request__c];
        
        REIDP_Application_Access_Request__c request = newAccessRequests.get(0);
        
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment
                                             WHERE AssigneeId = :UserInfo.getUserId() 
                                             AND PermissionSetId = :request.Application__r.Permission_Set__c];
        
        System.assertEquals(1, newAccessRequests.size());
        System.assertEquals(0, psa.size());
        
        Test.startTest();
        request.Status__c = 'Approved';
        update request;
        Test.stopTest();
        
        psa = [SELECT Id FROM PermissionSetAssignment
               WHERE AssigneeId = :UserInfo.getUserId() 
               AND PermissionSetId = :request.Application__r.Permission_Set__c];
        
        System.assertEquals(1, psa.size());
        
    }

	
    @isTest // this method is for REIDP_ApplicationAccessTriggerHandler afterUpdate()
    public static void processRejectedRequests() {
        REIDP_Application_Access_Request__c request = [SELECT Id, Application__r.Permission_Set__c 
                                                       FROM REIDP_Application_Access_Request__c 
                                                       LIMIT 1];
        
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment
                                             WHERE AssigneeId = :UserInfo.getUserId() 
                                             AND PermissionSetId = :request.Application__r.Permission_Set__c];
        
        System.assertEquals(0, psa.size());
        
        Test.startTest();
        request.Status__c = 'Rejected';
        update request;
        Test.stopTest();
        
        psa = [SELECT Id FROM PermissionSetAssignment
               WHERE AssigneeId = :UserInfo.getUserId() 
               AND PermissionSetId = :request.Application__r.Permission_Set__c];
        
        System.assertEquals(0, psa.size());
        
    }
    
    @isTest
    static void testBatchRejectAccessRequestsJob() {
        Test.startTest();
        REIDP_BatchRejectAccessRequestScheduler job = new REIDP_BatchRejectAccessRequestScheduler();   
        String cronExp = '0 0 12 * * ?';
        String jobId = System.schedule('REIDP_BatchRejectAccessRequestScheduler', cronExp, job);
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id , CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression); 
    }
    
    @isTest
    static void testBatchRejectAccessRequests() {   
        
        REIDP_Application_Access_Request__c aar = [SELECT Id, Status__c FROM REIDP_Application_Access_Request__c LIMIT 1];        
        
        Test.setCreatedDate(aar.Id, System.now() - 365);
        
        System.assertEquals('New', aar.Status__c);
        
        Test.startTest();
        REIDP_BatchRejectAccessRequests batchAutoRejectAccessRequests = new REIDP_BatchRejectAccessRequests ();
        database.executebatch(batchAutoRejectAccessRequests);
        Test.stopTest();
        
        aar = [SELECT Id, Status__c FROM REIDP_Application_Access_Request__c LIMIT 1]; 
        
        System.assertEquals('Rejected', aar.Status__c);
    }
    
    @future
    public static void createPermissionSet() {
        PermissionSet ps = new PermissionSet(Label='REIDP_ApplicationAccessServiceTest' + System.now().getTime() , 
                                             Name='REIDP_ApplicationAccessServiceTest' + System.now().getTime());
        insert ps;
    }
    
}