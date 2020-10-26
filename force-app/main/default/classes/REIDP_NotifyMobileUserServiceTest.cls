/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 21/09/2018
*
**/

@isTest
public class REIDP_NotifyMobileUserServiceTest {
    
    @isTest
    public static void testExecuteReject() {
        // create user with phone number username
        List<User> users = new List<User>();
        users.add(REIDP_TestFactory.createCommunityPhoneNumberUser());
        
        Test.startTest();
        REIDP_NotifyMobileUserService smsRejectSMS = new REIDP_NotifyMobileUserService(users, true);
        ID jobId = System.enqueueJob(smsRejectSMS);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
    
    @isTest
    public static void testExecuteAccess() {
        // create user with phone number username
        List<User> users = new List<User>();
        users.add(REIDP_TestFactory.createCommunityPhoneNumberUser());
        
        Test.startTest();
        REIDP_NotifyMobileUserService smsRejectSMS = new REIDP_NotifyMobileUserService(users);
        ID jobId = System.enqueueJob(smsRejectSMS);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}