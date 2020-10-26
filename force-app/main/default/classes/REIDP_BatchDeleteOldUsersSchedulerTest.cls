/**
* @author Nazim Aliyev
* @company Bluewolf, an IBM Company
* @date 1/2019
*
*/
@isTest
private class REIDP_BatchDeleteOldUsersSchedulerTest {
    
    @isTest
    static void testBatchDeleteOldUserAccounts() {
        User u = REIDP_TestFactory.createCommunityUser(REIDP_BatchDeleteOldUsersSchedulerTest.class);
        Test.setCreatedDate(u.id, System.now() - (365*3));
        
        Test.startTest();
        REIDP_BatchDeleteOldUsersScheduler batchOldAccs = new REIDP_BatchDeleteOldUsersScheduler();   
        String cronExp = '0 0 12 * * ?';
        String jobId = System.schedule('REIDP_BatchDeleteOldUsersScheduler', cronExp, batchOldAccs);
        Test.stopTest();
        CronTrigger ct = [SELECT Id , CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression); 

    }
}