/**
 * @author Ragim Ragimov
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * A test class for Controller that is used in NewDeviceComponent Visualforce component in BP Community
 */
@isTest 
public class REIDP_NewDeviceComponentControllerTest {
	@isTest
    public static void testUserWithNoDeviceInfo() {
        Test.startTest();
        User testUser = REIDP_NewDeviceNotificationPluginTest.testUser;
        System.runAs(testUser) {
            REIDP_NewDeviceComponentController newDevController = new REIDP_NewDeviceComponentController();
            newDevController.userId = testUser.Id;
            System.assertEquals(null, newDevController.getDeviceInfo());       
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testUserWithDeviceInfo() {
        Test.startTest();
        User testUser = REIDP_NewDeviceNotificationPluginTest.testUser;
        System.runAs(testUser) {
            Map<String, DateTime> deviceDateMap = new Map<String,DateTime>();
            deviceDateMap.put('OS!Device!Browser', DateTime.now());
            testUser.REIDP_Devices__c = JSON.serialize(deviceDateMap);
            update testUser;
            REIDP_NewDeviceComponentController newDevController = new REIDP_NewDeviceComponentController();
            newDevController.userId = testUser.Id;
            List<List<String>> result = newDevController.getDeviceInfo();
            System.assertEquals(2,result.size());
            System.assertEquals('Operating System', result.get(0).get(0));
            System.assertEquals('OS', result.get(0).get(1));
            System.assertEquals('Browser', result.get(1).get(0));
            System.assertEquals('Browser', result.get(1).get(1));
        }
        Test.stopTest();
    } 
    
    @isTest
    public static void testNoUserSet() {
        Test.startTest();
        REIDP_NewDeviceComponentController newDevController = new REIDP_NewDeviceComponentController();
        System.assertEquals(null, newDevController.getDeviceInfo());       
        Test.stopTest();
    }
}