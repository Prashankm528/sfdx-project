/**
* 
* @author Anna Mokhubova
* @company Bluewolf, an IBM Company
* @date 25/09/2018
*
**/

@isTest
public class REIDP_NotifyMobileUserNewDeviceTest {

    @isTest
    public static void testExecuteReject() {
        // create user with phone number username
        List<User> users = new List<User>();
        users.add(REIDP_TestFactory.createCommunityPhoneNumberUser());
        
        Test.startTest();
        REIDP_NotifyMobileUserNewDevice sms = new REIDP_NotifyMobileUserNewDevice(users);
        ID jobId = System.enqueueJob(sms);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
    
}