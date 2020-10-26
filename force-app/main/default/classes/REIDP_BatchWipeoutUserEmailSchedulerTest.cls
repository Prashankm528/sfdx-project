/**
*
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 04/2019
*
**/ 

@isTest
public class REIDP_BatchWipeoutUserEmailSchedulerTest {
    
    @TestSetup
    static void setup() {
        User u = REIDP_TestFactory.createCommunityUser(REIDP_BatchWipeoutUserEmailSchedulerTest.class);
        u.Email = 'SometestEmail@test35465762871.com';
        update u;
    }
    
    @isTest
    static void testBatchWipeoutUserEmailScheduler() {
        Test.startTest();
        REIDP_BatchWipeoutUserEmailScheduler batchWipeOutEmails = new REIDP_BatchWipeoutUserEmailScheduler();   
        String cronExp = '0 0 22 ? * 6L';
        String jobId = System.schedule('REIDP_BatchWipeoutUserEmailScheduler', cronExp, batchWipeOutEmails);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        CronTrigger ct = [SELECT Id , CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression); 
    }
    
    @isTest
    static void testBatchWipeoutUserEmailBatch() {
        User u = [SELECT Id, Email, REIDP_New_Email__c, REIDP_Verified_Email__c, REIDP_New_Email_TimeStamp__c FROM User WHERE REIDP_New_Email__c =: 'SometestEmail@test35465762871.com'];
        u.Email = 'SometestEmail@test35465762871.com';
        u.REIDP_Verified_Email__c = u.Email;
        Datetime dt = System.now();
        u.REIDP_New_Email_TimeStamp__c = dt.addDays(-90);
        update u;
 
        Test.startTest();
        REIDP_BatchWipeoutUserEmail bwe = new REIDP_BatchWipeoutUserEmail();
        Id batchId = Database.executeBatch(bwe);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(null, [SELECT REIDP_New_Email__c FROM User WHERE Id =: u.Id].REIDP_New_Email__c);
        System.assertEquals(null, [SELECT REIDP_New_Email_TimeStamp__c FROM User WHERE Id =: u.Id].REIDP_New_Email_TimeStamp__c);
        System.assertEquals('Completed', [SELECT Status FROM AsyncApexJob WHERE Id =: batchId].Status);

    }
    
}