/**
 * @author Ragim Ragimov
 * @company Bluewolf, an IBM Company
 * @date 7/2017
 *
 * A test class for Flow Plugin used to detect New Devices user logs in from in BP Community
 */
@isTest 
public class REIDP_NewDeviceNotificationPluginTest {
    
    public static User testUser {
        public get {
            if(testUser == null)
                testUser = createTestUser();
            return testUser;
        }
    }
    
    public static User testPhoneNumberUser {
        public get {
            if(testPhoneNumberUser == null)
                testPhoneNumberUser = REIDP_TestFactory.createCommunityPhoneNumberUser();
            return testPhoneNumberUser;
        }
    }
    
    @isTest
    static void testNewDevice() {
        Test.startTest();
        REIDP_NewDeviceNotificationPlugin plugin = new REIDP_NewDeviceNotificationPlugin();
        plugin.describe();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('LoginFlow_UserAgent', 'TestUserAgent');
        inputParams.put('LoginFlow_Platform', 'TestPlatform');
        inputParams.put('Email_Template', 'REIDP_New_Device_Email');
     
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        System.runAs(testUser) {
            Process.PluginResult result = plugin.invoke(request);
            System.assertEquals(result.outputParameters.get('NewDevice'),true);       
        } 
        Test.stopTest();
    }
    
    @isTest
    static void testSameDevice() {
        Test.startTest();
        REIDP_NewDeviceNotificationPlugin plugin = new REIDP_NewDeviceNotificationPlugin();
        plugin.describe();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('LoginFlow_UserAgent', 'TestUserAgent');
        inputParams.put('LoginFlow_Platform', 'TestPlatform');
        inputParams.put('Email_Template', 'REIDP_New_Device_Email');
     
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        System.runAs(testUser) {
            Process.PluginResult result = plugin.invoke(request);
            result = plugin.invoke(request);
            System.assertEquals(result.outputParameters.get('NewDevice'),false);       
        } 
        Test.stopTest();
    }
    
    @isTest
    static void testCorruptedDeviceField() {
        Test.startTest();
        REIDP_NewDeviceNotificationPlugin plugin = new REIDP_NewDeviceNotificationPlugin();
        plugin.describe();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('LoginFlow_UserAgent', 'TestUserAgent');
        inputParams.put('LoginFlow_Platform', 'TestPlatform');
        inputParams.put('Email_Template', 'REIDP_New_Device_Email');
     
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        System.runAs(testUser) {
            testUser.REIDP_Devices__c = 'testData';
            update testUser;
            Process.PluginResult result = plugin.invoke(request);
            System.assertEquals(result.outputParameters.get('NewDevice'),true);       
        } 
        Test.stopTest();
    }
    
    @isTest
    static void testManyDevices() {
        Test.startTest();
        Map<String, DateTime> deviceDateMap = new Map<String,DateTime>();
        String deviceId = 'deviceId';
        for(Integer i = 0; i < 151; i++) {
            deviceDateMap.put(deviceId + i, DateTime.now());
        }
        REIDP_NewDeviceNotificationPlugin plugin = new REIDP_NewDeviceNotificationPlugin();
        plugin.describe();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('LoginFlow_UserAgent', 'TestUserAgent');
        inputParams.put('LoginFlow_Platform', 'TestPlatform');
        inputParams.put('Email_Template', 'REIDP_New_Device_Email');
        
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        System.runAs(testUser) {
            testUser.REIDP_Devices__c = JSON.serialize(deviceDateMap);
            update testUser;
            Process.PluginResult result = plugin.invoke(request);
            System.assertEquals(result.outputParameters.get('NewDevice'),true);
        } 
        Test.stopTest();
    }
    
    @isTest
    static void testSameDevicePhoneNumberUser() {
        Test.startTest();
        REIDP_NewDeviceNotificationPlugin plugin = new REIDP_NewDeviceNotificationPlugin();
        plugin.describe();
        Map<String,Object> inputParams = new Map<String,Object>();
        inputParams.put('LoginFlow_UserAgent', 'TestUserAgent');
        inputParams.put('LoginFlow_Platform', 'TestPlatform');
        inputParams.put('Email_Template', 'REIDP_New_Device_Email');
     
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        System.runAs(testPhoneNumberUser) {
            Process.PluginResult result = plugin.invoke(request);
            result = plugin.invoke(request);
            System.assertEquals(result.outputParameters.get('NewDevice'),false);       
        } 
        Test.stopTest();
    }
    
    public static User createTestUser() {
        String orgId = UserInfo.getOrganizationId();
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User tuser = new User(firstname = 'Test',
                              lastName = 'Test',
                              email = 'newDeviceTest@test' + orgId + '.org',
                              Username = 'newDeviceTest@test' + orgId + '.org',
                              Alias = 'ndTest',
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              EmailEncodingKey = 'ISO-8859-1',
                              ProfileId = pf.Id,
                              UserRoleId = ur.Id);
        return tuser;
    }
}