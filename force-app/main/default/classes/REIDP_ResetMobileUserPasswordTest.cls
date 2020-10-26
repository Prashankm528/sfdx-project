/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 04/09/2018
*
**/
@isTest
public class REIDP_ResetMobileUserPasswordTest {
    
    @isTest
    public static void testExecuteWelcome() {
        List<User> users = new List<User>();
        users.add(REIDP_TestFactory.createCommunityPhoneNumberUser());
        
        Test.startTest();
        REIDP_ResetMobileUserPassword smsResetSMS = new REIDP_ResetMobileUserPassword(users);
        ID jobId = System.enqueueJob(smsResetSMS);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
    
    @isTest
    public static void testExecuteReset() {
        List<User> users = new List<User>();
        users.add(REIDP_TestFactory.createCommunityPhoneNumberUser());
        
        Test.startTest();
        REIDP_ResetMobileUserPassword smsResetSMS = new REIDP_ResetMobileUserPassword(users, true);
        ID jobId = System.enqueueJob(smsResetSMS);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}